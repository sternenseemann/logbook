open Jg_types

let string_of_date (y, m, d) =
  string_of_int y ^ "-" ^ string_of_int m ^ "-" ^ string_of_int d

let data_model_of_items mode items =
  Log.filter_privacy_level mode items
  |> List.map (fun (Log.Item (_, tt, tx)) ->
      Tobj [ ("title", Tstr tt); ("text", Tstr tx); ])

let model_of_log title level log =
  [ ("title", Tstr title);
    ("entries", Tlist (List.map
    (fun (Log.Log_entry (date, summary, items)) ->
      Tobj [
        ("summary", Tstr summary);
        ("date", Tstr (string_of_date date));
        ("items", Tlist (data_model_of_items level items));
      ])
    log)) ]

