(*---------------------------------------------------------------------------
   Copyright (c) 2017 sternenseemann. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
   %%NAME%% %%VERSION%%
  ---------------------------------------------------------------------------*)
open Angstrom
open Astring

type privacy_level = Private | Semi_private | Public

let compatible_privacy x mode =
  match mode with
  | Private -> true (* who may see private posts, may see all posts *)
  | Semi_private -> x = Semi_private || x = Public
  | Public -> x = Public

let privacy_level_of_char = function
  | '+' -> Some Public
  | '-' -> Some Private
  | '*' -> Some Semi_private
  | _   -> None

type 'a item = Item of privacy_level * 'a * 'a

let filter_privacy_level mode items =
  List.filter (fun (Item (p, _, _)) -> compatible_privacy p mode) items

type 'a log_entry = Log_entry of Ptime.date * 'a * ('a item) list

type 'a log = ('a log_entry) list

(* parser *)

let empty_line = end_of_line
let non_empty_line = take_while1 (fun c -> c != '\n') <* end_of_line

let editor_comment = string "-*-"
  *> skip_while (fun c -> c != '\n')
  *> end_of_line

let date =
  (fun y m d -> (int_of_string y, int_of_string m, int_of_string d))
  <$> (char '[' *> take_till (fun c -> c = '-') <* char '-')
  <*> (take 2 <* char '-')
  <*> (take 2 <* char ']' <* end_of_line)

let spaced_list p =
  many (p <* skip_many empty_line)

let fail_if_none p =
  let failer = function
    | None -> fail "Value is None"
    | Some x -> return x
  in p >>= failer

let rec block indent =
  let checkforblock = function
    | None -> false
    | Some '\n' -> false
    | Some c -> if indent > 0 then c = ' ' else true
  in String.append
    <$> (count indent (char ' ') *> non_empty_line)
    <*> (peek_char
      >>= (fun c ->
        if (checkforblock c) then (String.append "\n") <$> block indent
        else return ""))

let itemp =
  (fun p tt tx -> Item (p, tt, tx))
  <$> (fail_if_none (privacy_level_of_char <$> any_char) <* char ' ')
  <*> non_empty_line
  <*> block 2

let log_entryp =
  (fun d s i -> Log_entry (d, s, i))
  <$> (date <* skip_many empty_line)
  <*> block 0
  <*> (skip_many empty_line *> spaced_list itemp)

(* Parser TODO
 * - substitutions
 * - markdown/other markup
 * - proper failure if not
 *   the whole output is consumed
 * …
 *)
let log_parser =
  (editor_comment <|> return ()) *>
  skip_many empty_line *>
  spaced_list log_entryp

(* processing *)

let apply_markup markup log =
  let apply_items items =
    List.map (fun (Item (priv, title, block)) ->
      Item (priv, (markup title), (markup block))) items in
  List.map (fun (Log_entry (date, summary, items)) ->
    Log_entry (date, (markup summary), (apply_items items))) log

(*---------------------------------------------------------------------------
   Copyright (c) 2017 sternenseemann

   Permission to use, copy, modify, and/or distribute this software for any
   purpose with or without fee is hereby granted, provided that the above
   copyright notice and this permission notice appear in all copies.

   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
   WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
   MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
   ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
   WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
   ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
   OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  ---------------------------------------------------------------------------*)
