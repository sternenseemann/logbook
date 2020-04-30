open Lwt
open Lwt.Infix
open Cow

let parse_file f =
  let file_parser c =
    Lwt_io.read c >>= (fun s ->
      return (Angstrom.parse_string ~consume:All Log.log_parser s))
  in match f with
     | None -> file_parser Lwt_io.stdin
     | Some filename -> Lwt_io.with_file ~mode:Lwt_io.Input filename file_parser

let input_file = ref None
let privacy = ref Log.Public
let markup = ref (fun s -> Html.p (Html.string s))
let title = ref "log"

let arglist =
  [ ("--file", Arg.String (fun f -> input_file := Some f), "log file to use");
    ("--private", Arg.Unit (fun () -> privacy := Log.Private),
    "set privacy level of output to private");
    ("--public", Arg.Unit (fun () -> privacy := Log.Public),
    "set privacy level of output to public");
    ("--semi-private", Arg.Unit (fun () -> privacy := Log.Semi_private),
    "set privacy level of output to semi-private");
    ("--markdown", Arg.Unit (fun () -> markup := Markdown.of_string),
    "enable markdown markup");
    ("--title", Arg.String (fun f -> title := f), "title of the generated html document");
  ]

let usage =
  Sys.argv.(0) ^ " --file [file.log]" ^
  " [--public | --private | --semi-private]" ^
  " [--markdown]"

let _ =
  Arg.parse arglist (fun _ -> ()) usage;
  let log = Lwt_main.run (parse_file !input_file >>= fun log ->
      match log with
      | Result.Error msg -> failwith ("Parse error (" ^ msg ^ ")")
      | Result.Ok log -> return log)
  in
  let log_markup =
    Log.apply_markup (fun x -> Xml.to_string ~decl:false (!markup x)) log
  in print_string (Jg_template.from_string
    Logbook_template.template
    ~models:(Logbook_models.model_of_log !title !privacy log_markup))
