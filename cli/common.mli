open Duniverse_lib

module Logs : sig
  val app : ?src:Logs.src -> 'a Logs.log
  (** Formats the arguments and logs the resulting message with app level, preceded by a sexy looking
      ["==> "] blue header. *)
end

module Arg : sig
  val named : ('a -> 'b) -> 'a Cmdliner.Term.t -> 'b Cmdliner.Term.t
  (** Use this to wrap your arguments in a polymorphic variant constructor to avoid
      confusion when they are later passed to your main function.
      Example: [named (fun x -> `My_arg x] Arg.(value ...)] *)

  val fpath : Fpath.t Cmdliner.Arg.conv

  val root : [ `Root of Fpath.t ] Cmdliner.Term.t
  (** CLI option to specify the root directory of the project. Used to find root packages,
      duniverse files and directories. Defaults to the current directory. *)

  val lockfile : [ `Lockfile of Fpath.t option ] Cmdliner.Term.t
  (** CLI option to specify the path to the lockfile to use or generate. *)

  val yes : [ `Yes of bool ] Cmdliner.Term.t
  (** CLI flag to skip any prompt and perform actions straight away. The value of this flag
      must be passed to [Prompt.confirm]. *)

  val duniverse_repos :
    [ `Duniverse_repos of string list option ] Cmdliner.Term.t
  (** CLI arguments consisting of the list of source deps repo to process. If [None],
      the whole duniverse should be processed. If [Some l] then [l] is non empty. *)

  val keep_git_dir : [ `Keep_git_dir of bool ] Cmdliner.Term.t
  (** CLI flag to keep the [.git] directory after pulling the vendored sources. *)

  val keep_symlinked_dir : [ `Keep_symlinked_dir of bool ] Cmdliner.Term.t
  (** CLI flag to preserve vendored directories that are symlinked. *)

  val setup_logs : unit -> unit Cmdliner.Term.t
  (** Adds the common options -v and --version and sets up the logs before being passed as [()] to a
      command. *)

  val version : string
  (** CLI version string *)
end

module Term : sig
  val result_to_exit :
    (unit, [< `Msg of string ]) result Cmdliner.Term.t -> int Cmdliner.Term.t
  (** Converts a [_ result Term.t] to an [int Term.t] embedding the right exit
      status. *)
end

val exit_codes : Cmdliner.Cmd.Exit.info list

val filter_duniverse :
  to_consider:string list option ->
  Duniverse.t ->
  (Duniverse.t, Rresult.R.msg) result
(** Filters the duniverse according to the CLI provided list of repos or returns an error
    if some of the provided packages don't match any of the duniverse repositories. *)

val find_lockfile :
  explicit_lockfile:Fpath.t option ->
  ?quiet:bool ->
  Fpath.t ->
  (Lockfile.t, Rresult.R.msg) result
