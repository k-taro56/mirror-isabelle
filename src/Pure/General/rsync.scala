/*  Title:      Pure/General/rsync.scala
    Author:     Makarius

Support for rsync, based on Isabelle component.
*/

package isabelle


object Rsync {
  object Context {
    def apply(
      progress: Progress = new Progress,
      ssh: SSH.System = SSH.Local,
      archive: Boolean = true,
      stats: Boolean = true
    ): Context = {
      val directory = Components.provide(Component_Rsync.home, ssh = ssh, progress = progress)
      new Context(directory, progress, archive, stats)
    }
  }

  final class Context private(
    directory: Components.Directory,
    val progress: Progress,
    archive: Boolean,
    stats: Boolean
  ) {
    override def toString: String = directory.toString

    def ssh: SSH.System = directory.ssh

    def command: String = {
      val program = Component_Rsync.remote_program(directory)
      val ssh_command = ssh.client_command
      File.bash_path(Component_Rsync.local_program) + " --secluded-args" +
        if_proper(ssh_command, " --rsh=" + Bash.string(ssh_command)) +
        " --rsync-path=" + Bash.string(quote(File.standard_path(program))) +
        (if (archive) " --archive" else "") +
        (if (stats) " --stats" else "")
    }

    def target(path: Path, direct: Boolean = false): String =
      Url.dir_path(ssh.rsync_path(path), direct = direct)
  }

  def exec(
    context: Context,
    thorough: Boolean = false,
    prune_empty_dirs: Boolean = false,
    dry_run: Boolean = false,
    clean: Boolean = false,
    filter: List[String] = Nil,
    args: List[String] = Nil
  ): Process_Result = {
    val progress = context.progress
    val script =
      context.command +
        (if (progress.verbose) " --verbose" else "") +
        (if (thorough) " --ignore-times" else " --omit-dir-times") +
        (if (prune_empty_dirs) " --prune-empty-dirs" else "") +
        (if (dry_run) " --dry-run" else "") +
        (if (clean) " --delete-excluded" else "") +
        filter.map(s => " --filter=" + Bash.string(s)).mkString +
        if_proper(args, " " + Bash.strings(args))
    progress.bash(script, echo = true)
  }
}
