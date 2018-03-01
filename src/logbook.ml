open Lwt
open Lwt.Infix

let parse_file f =
  Lwt_io.with_file Lwt_io.Input f (fun c ->
    Lwt_io.read c >>= (fun s ->
      return (Angstrom.parse_string Log.log_parser s)))

let input_file = ref None
let privacy = ref Log.Public
let markup = ref (fun s -> Cow_html.p (Cow_html.string s))

let arglist =
  [ ("--file", Arg.String (fun f -> input_file := Some f), "log file to use");
    ("--private", Arg.Unit (fun () -> privacy := Log.Private),
    "set privacy level of output to private");
    ("--public", Arg.Unit (fun () -> privacy := Log.Public),
    "set privacy level of output to public");
    ("--semi-private", Arg.Unit (fun () -> privacy := Log.Semi_private),
    "set privacy level of output to semi-private");
    ("--markdown", Arg.Unit (fun () -> markup := Cow_markdown.of_string),
    "enable markdown markup");
  ]

let usage =
  Sys.argv.(0) ^ " --file [file.log]" ^
  " [--public | --private | --semi-private]" ^
  " [--markdown]"

let _ =
  Arg.parse arglist (fun _ -> ()) usage;
  match !input_file with
  | None -> print_endline "No file supplied"
  | Some f -> let log = Lwt_main.run (parse_file f >>= fun log ->
      match log with
      | Result.Error msg -> failwith msg
      | Result.Ok log -> return log)
  in
  let log_markup =
    Log.apply_markup (fun x -> Cow_xml.to_string ~decl:false (!markup x)) log
  in print_string (Jg_template.from_string
    Logbook_template.template
    ~models:(Logbook_models.model_of_log !privacy log_markup))
