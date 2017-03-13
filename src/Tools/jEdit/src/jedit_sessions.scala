/*  Title:      Tools/jEdit/src/jedit_sessions.scala
    Author:     Makarius

Isabelle/jEdit session information.
*/

package isabelle.jedit


import isabelle._

import scala.swing.ComboBox
import scala.swing.event.SelectionChanged


object JEdit_Sessions
{
  /* session info */

  private val option_name = "jedit_logic"

  sealed case class Info(name: String, open_root: Position.T)

  def session_dirs(): List[Path] = Path.split(Isabelle_System.getenv("JEDIT_SESSION_DIRS"))

  def session_options(): Options =
    Isabelle_System.getenv("JEDIT_ML_PROCESS_POLICY") match {
      case "" => PIDE.options.value
      case s => PIDE.options.value.string("ML_process_policy") = s
    }

  def session_info(): Info =
  {
    val logic =
      Isabelle_System.default_logic(
        Isabelle_System.getenv("JEDIT_LOGIC"),
        PIDE.options.string(option_name))

    (for {
      tree <-
        try { Some(Sessions.load(session_options(), dirs = session_dirs())) }
        catch { case ERROR(_) => None }
      info <- tree.lift(logic)
      parent <- info.parent
      if Isabelle_System.getenv("JEDIT_LOGIC_ROOT") == "true"
    } yield Info(parent, info.pos)) getOrElse Info(logic, Position.none)
  }

  def session_name(): String = session_info().name

  def session_build_mode(): String = Isabelle_System.getenv("JEDIT_BUILD_MODE")

  def session_build(progress: Progress = No_Progress, no_build: Boolean = false): Int =
  {
    val mode = session_build_mode()

    Build.build(options = session_options(), progress = progress,
      build_heap = true, no_build = no_build, system_mode = mode == "" || mode == "system",
      dirs = session_dirs(), sessions = List(session_name())).rc
  }

  def session_start()
  {
    val modes =
      (space_explode(',', PIDE.options.string("jedit_print_mode")) :::
       space_explode(',', Isabelle_System.getenv("JEDIT_PRINT_MODE"))).reverse

    Isabelle_Process.start(PIDE.session, session_options(),
      logic = session_name(), dirs = session_dirs(), modes = modes,
      store = Sessions.store(session_build_mode() == "system"))
  }

  def session_list(): List[String] =
  {
    val session_tree = Sessions.load(PIDE.options.value, dirs = session_dirs())
    val (main_sessions, other_sessions) =
      session_tree.topological_order.partition(p => p._2.groups.contains("main"))
    main_sessions.map(_._1).sorted ::: other_sessions.map(_._1).sorted
  }

  def session_base(): Sessions.Base =
  {
    val base =
      try { Build.session_base(PIDE.options.value, session_name(), session_dirs()) }
      catch { case ERROR(_) => Sessions.Base.empty }
    base.copy(known_theories = base.known_theories.mapValues(a => a.map(File.platform_path(_))))
  }


  /* logic selector */

  private class Logic_Entry(val name: String, val description: String)
  {
    override def toString: String = description
  }

  def logic_selector(autosave: Boolean): Option_Component =
  {
    GUI_Thread.require {}

    val entries =
      new Logic_Entry("", "default (" + session_name() + ")") ::
        session_list().map(name => new Logic_Entry(name, name))

    val component = new ComboBox(entries) with Option_Component {
      name = option_name
      val title = "Logic"
      def load: Unit =
      {
        val logic = PIDE.options.string(option_name)
        entries.find(_.name == logic) match {
          case Some(entry) => selection.item = entry
          case None =>
        }
      }
      def save: Unit = PIDE.options.string(option_name) = selection.item.name
    }

    component.load()
    if (autosave) {
      component.listenTo(component.selection)
      component.reactions += { case SelectionChanged(_) => component.save() }
    }
    component.tooltip = "Logic session name (change requires restart)"
    component
  }
}
