/*  Title:      Pure/Admin/build_foiltex.scala
    Author:     Makarius

Build Isabelle component for FoilTeX.

See also https://ctan.org/pkg/foiltex
*/

package isabelle


object Build_Foiltex {
  /* build FoilTeX component */

  val default_url = "https://mirrors.ctan.org/macros/latex/contrib/foiltex.zip"

  def build_foiltex(
    download_url: String = default_url,
    target_dir: Path = Path.current,
    progress: Progress = new Progress
  ): Unit = {
    Isabelle_System.require_command("unzip", test = "-h")

    Isabelle_System.with_tmp_file("download", ext = "zip") { download_file =>
      Isabelle_System.with_tmp_dir("download") { download_dir =>

        /* download */

        Isabelle_System.download_file(download_url, download_file, progress = progress)
        Isabelle_System.bash("unzip -x " + File.bash_path(download_file),
          cwd = download_dir.file).check

        val foiltex_dir =
          File.read_dir(download_dir) match {
            case List(name) => download_dir + Path.explode(name)
            case bad =>
              error("Expected exactly one directory entry in " + download_file +
                bad.mkString("\n", "\n  ", ""))
          }

        val README = Path.explode("README")
        val README_flt = Path.explode("README.flt")
        Isabelle_System.move_file(foiltex_dir + README, foiltex_dir + README_flt)

        Isabelle_System.bash("pdflatex foiltex.ins", cwd = foiltex_dir.file).check


        /* component */

        val version = {
          val Version = """^.*Instructions for FoilTeX Version\s*(.*)$""".r
          split_lines(File.read(foiltex_dir + README_flt))
            .collectFirst({ case Version(v) => v })
            .getOrElse(error("Failed to detect version in " + README_flt))
        }

        val component = "foiltex-" + version
        val component_dir = Isabelle_System.new_directory(target_dir + Path.basic(component))
        progress.echo("Component " + component_dir)

        component_dir.file.delete
        Isabelle_System.copy_dir(foiltex_dir, component_dir)


        /* settings */

        val etc_dir = Isabelle_System.make_directory(component_dir + Path.basic("etc"))
        File.write(etc_dir + Path.basic("settings"),
          """# -*- shell-script -*- :mode=shellscript:

ISABELLE_FOILTEX_HOME="$COMPONENT"
""")


        /* README */

        File.write(component_dir + Path.basic("README"),
          """This is FoilTeX from
""" + download_url + """


    Makarius
    """ + Date.Format.date(Date.now()) + "\n")
      }
    }
  }


  /* Isabelle tool wrapper */

  val isabelle_tool =
    Isabelle_Tool("build_foiltex", "build component for FoilTeX",
      Scala_Project.here,
      { args =>
        var target_dir = Path.current
        var download_url = default_url

        val getopts = Getopts("""
Usage: isabelle build_foiltex [OPTIONS]

  Options are:
    -D DIR       target directory (default ".")
    -U URL       download URL (default: """" + default_url + """")

  Build component for FoilTeX: slides in LaTeX.
""",
          "D:" -> (arg => target_dir = Path.explode(arg)),
          "U:" -> (arg => download_url = arg))

        val more_args = getopts(args)
        if (more_args.nonEmpty) getopts.usage()

        val progress = new Console_Progress()

        build_foiltex(download_url = download_url, target_dir = target_dir, progress = progress)
      })
}