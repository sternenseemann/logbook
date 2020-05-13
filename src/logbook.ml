open Stdlib
open Lwt.Infix
open Cow
open Jingoo

let parse_file f =
  let file_parser c =
    Lwt_io.read c >>= (fun s ->
      Lwt.return (Result.map_error (fun e -> "Parse error:" ^ e)
                   (Angstrom.parse_string ~consume:All Log.log_parser s)))
  in match f with
     | None -> file_parser Lwt_io.stdin
     | Some filename ->
         try (Lwt_io.with_file ~mode:Lwt_io.Input filename file_parser)
         with Unix.Unix_error (e, _, _) ->
           Lwt.return (Result.Error ("Failed opening file:" ^ Unix.error_message e))

let get_template f =
  match f with
  | None -> Result.Ok Logbook_template.template
  | Some name ->
      try Result.Ok (Lwt_main.run (Lwt_io.with_file ~mode:Lwt_io.Input name Lwt_io.read))
      with Unix.Unix_error (e, _, _) ->
        Result.Error ("Failed reading template:" ^ Unix.error_message e)

let html_of_log log markup template privacy title =
  try Result.Ok (Jg_template.from_string template
        ~models:(Logbook_models.model_of_log title privacy
          (Log.apply_markup (fun
            x -> Xml.to_string ~decl:false (markup x)) log)))
     with Jg_types.SyntaxError msg ->
       Result.Error ("Template syntax error:" ^ msg)

let input_file = ref None
let privacy = ref Log.Public
let markup = ref (fun s -> Html.string s)
let title = ref "log"
let template_file = ref None

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
    ("--paragraph", Arg.Unit (fun () -> markup := (fun s -> Html.p (Html.string s))), "Wrap summary, item titles and texts with <p>, like for example markdown does, but without applying any markup");
    ("--title", Arg.String (fun f -> title := f), "title of the generated html document");
    ("--template", Arg.String (fun f -> template_file := Some f), "Jingoo template to use for HTML generation");
  ]

let usage =
  Sys.argv.(0) ^ " [--file <file.log>]" ^
  " [--template <template.html.jingoo>]" ^
  " [--public | --private | --semi-private]" ^
  " [--markdown]" ^ " [--title <title>]"

let _ =
  Arg.parse arglist (fun _ -> ()) usage;
  let result = Result.bind (Lwt_main.run (parse_file !input_file)) (fun log ->
    Result.bind (get_template !template_file) (fun tpl ->
      html_of_log log !markup tpl !privacy !title))
  in match result with
     | Result.Ok s -> print_endline s; exit 0
     | Result.Error e -> print_endline e; exit 1
