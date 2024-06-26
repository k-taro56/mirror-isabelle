/*  Title:      Pure/Admin/ci_build.scala
    Author:     Lars Hupel and Fabian Huch, TU Munich

Build profile for continuous integration services.
*/

package isabelle


import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.{Properties => JProperties, Map => JMap}
import java.nio.file.Files


object CI_Build {
  /* build result */

  case class Result(rc: Int)
  case object Result {
    def ok: Result = Result(Process_Result.RC.ok)
    def error: Result = Result(Process_Result.RC.error)
  }


  /* executor profile */

  case class Profile(threads: Int, jobs: Int, numa: Boolean)

  object Profile {
    def from_host: Profile = {
      Isabelle_System.hostname() match {
        case "hpcisabelle" => Profile(8, 8, numa = true)
        case "lxcisa1" => Profile(4, 10, numa = false)
        case _ => Profile(2, 2, numa = false)
      }
    }
  }


  /* build config */

  case class Build_Config(
    documents: Boolean = true,
    clean: Boolean = true,
    include: List[Path] = Nil,
    select: List[Path] = Nil,
    pre_hook: Options => Result = _ => Result.ok,
    post_hook: (Build.Results, Options, Time) => Result = (_, _, _) => Result.ok,
    selection: Sessions.Selection = Sessions.Selection.empty)


  def mail_server(options: Options): Mail.Server = {
    val sender =
      proper_string(options.string("ci_mail_sender")).map(Mail.address) getOrElse
        Mail.default_address

    new Mail.Server(sender,
      smtp_host = options.string("ci_mail_smtp_host"),
      smtp_port = options.int("ci_mail_smtp_port"),
      user = options.string("ci_mail_user"),
      password = options.string("ci_mail_password"))
  }

  /* ci build jobs */

  sealed case class Job(name: String, description: String, profile: Profile, config: Build_Config) {
    override def toString: String = name
  }

  private lazy val known_jobs: List[Job] =
    Isabelle_System.make_services(classOf[Isabelle_CI_Builds]).flatMap(_.jobs)

  def show_jobs: String =
    cat_lines(known_jobs.sortBy(_.name).map(job => job.name + " - " + job.description))

  def the_job(name: String): Job = known_jobs.find(job => job.name == name) getOrElse
    error("Unknown job " + quote(name))

  val timing =
    Job(
      "benchmark", "runs benchmark and timing sessions",
      Profile(threads = 6, jobs = 1, numa = false),
      Build_Config(
        documents = false,
        select = List(
          Path.explode("$ISABELLE_HOME/src/Benchmarks")),
        selection = Sessions.Selection(session_groups = List("timing"))))


  /* session status */

  sealed abstract class Status(val str: String) {
    def merge(that: Status): Status = (this, that) match {
      case (Ok, s) => s
      case (Failed, _) => Failed
      case (Skipped, Failed) => Failed
      case (Skipped, _) => Skipped
    }
  }

  object Status {
    def merge(statuses: List[Status]): Status =
      statuses.foldLeft(Ok: Status)(_ merge _)

    def from_results(results: Build.Results, session: String): Status =
      if (results.cancelled(session)) Skipped
      else if (results(session).ok) Ok
      else Failed
  }

  case object Ok extends Status("ok")
  case object Skipped extends Status("skipped")
  case object Failed extends Status("failed")


  /* ci build */

  private def compute_timing(results: Build.Results, group: Option[String]): Timing = {
    val timings =
      results.sessions.collect {
        case session if group.forall(results.info(session).groups.contains(_)) =>
          results(session).timing
      }
    timings.foldLeft(Timing.zero)(_ + _)
  }

  private def with_documents(options: Options, config: Build_Config): Options = {
    if (config.documents) {
      options + "browser_info" + "document=pdf" + "document_variants=document:outline=/proof,/ML"
    }
    else options
  }

  def hg_id(path: Path): String =
    Mercurial.repository(path).id()

  def print_section(title: String): Unit =
    println("\n=== " + title + " ===\n")

  def ci_build(options: Options, job: Job): Unit = {
    val profile = job.profile
    val config = job.config

    val isabelle_home = Path.explode(Isabelle_System.getenv_strict("ISABELLE_HOME"))
    val isabelle_id = hg_id(isabelle_home)

    val start_time = Time.now()
    val formatted_time = start_time.instant.atZone(ZoneId.systemDefault).format(
      DateTimeFormatter.RFC_1123_DATE_TIME)

    print_section("CONFIGURATION")
    println(Build_Log.Settings.show())

    val build_options =
      with_documents(options, config).int.update("threads", profile.threads) +
        "parallel_proofs=1" + "system_heaps"

    println(
      "jobs = " + profile.jobs + ", threads = " + profile.threads + ", numa = " + profile.numa)

    print_section("BUILD")
    println("Build started at " + formatted_time)
    println("Isabelle id " + isabelle_id)
    val pre_result = config.pre_hook(options)

    print_section("LOG")
    val (results, elapsed_time) = {
      val progress = new Console_Progress(verbose = true)
      val start_time = Time.now()
      val results = progress.interrupt_handler {
        Build.build(
          build_options,
          selection = config.selection,
          progress = progress,
          clean_build = config.clean,
          numa_shuffling = profile.numa,
          max_jobs = Some(profile.jobs),
          dirs = config.include,
          select_dirs = config.select)
      }
      val end_time = Time.now()
      (results, end_time - start_time)
    }

    print_section("TIMING")

    val groups = results.sessions.map(results.info).flatMap(_.groups)
    for (group <- groups)
      println("Group " + group + ": " + compute_timing(results, Some(group)).message_resources)

    val total_timing = compute_timing(results, None).copy(elapsed = elapsed_time)
    println("Overall: " + total_timing.message_resources)

    if (!results.ok) {
      print_section("FAILED SESSIONS")

      for (name <- results.sessions) {
        if (results.cancelled(name)) println("Session " + name + ": CANCELLED")
        else {
          val result = results(name)
          if (!result.ok) println("Session " + name + ": FAILED " + result.rc)
        }
      }
    }

    val post_result = config.post_hook(results, options, start_time)

    sys.exit(List(pre_result.rc, results.rc, post_result.rc).max)
  }


  /* Isabelle tool wrapper */

  val isabelle_tool = Isabelle_Tool("ci_build", "builds Isabelle jobs in ci environments",
    Scala_Project.here,
    { args =>
      /* arguments */

      var options = Options.init()

      val getopts = Getopts("""
Usage: isabelle ci_build [OPTIONS] JOB

  Options are:
    -o OPTION    override Isabelle system OPTION (via NAME=VAL or NAME)

  Runs Isabelle builds in ci environment, with the following build jobs:

""" + Library.indent_lines(4, show_jobs) + "\n",
        "o:" -> (arg => options = options + arg))

      val more_args = getopts(args)

      val job = more_args match {
        case job :: Nil => the_job(job)
        case _ => getopts.usage()
      }

      ci_build(options, job)
    })
}

class Isabelle_CI_Builds(val jobs: CI_Build.Job*) extends Isabelle_System.Service

class CI_Builds extends Isabelle_CI_Builds(CI_Build.timing)
