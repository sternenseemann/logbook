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

type item = Item of privacy_level * string * string

type log_entry = Log_entry of Ptime.date * string * item list

type log = log_entry list

(* parser *)

let empty_line = end_of_line
let non_empty_line = take_while1 (fun c -> c != '\n') <* end_of_line

let editor_comment = string "-*-" *> skip_while (fun c -> c != '\n') *> end_of_line

let single_indent = count 4 (char ' ') *> return ()

let date =
  char '[' *>
  take_till (fun c -> c = '-') <* char '-'
  >>= (fun year ->
    take 2 <* char '-'
    >>= (fun month ->
      take 2 <* char ']' <* end_of_line
      >>= (fun day ->
        return (int_of_string year, int_of_string month, int_of_string day))))

let spaced_list p =
  many (p <* skip_many empty_line)

let rec fail_if_none p =
  let failer = function
    | None -> fail "Value is None"
    | Some x -> return x
  in p >>= failer

let rec block indent =
  let peeker = function
    | None -> false
    | Some '\n' -> false
    | Some _ -> true
  in String.append
    <$> (count indent (char ' ')
         *> non_empty_line)
    <*> (peek_char
      >>= (fun c ->
        if (peeker c) then (String.append "\n") <$> block indent
        else return ""))

let itemp =
  fail_if_none (privacy_level_of_char <$> any_char) <*
  any_char
  >>= (fun priv ->
    non_empty_line
    >>= (fun title ->
      block 2
      >>= (fun text ->
        return (Item (priv, title, text)))))

let log_entryp =
  date <* skip_many empty_line
  >>= (fun date ->
    block 0
    >>= (fun summary ->
      skip_many empty_line *>
      spaced_list itemp
      >>= (fun items ->
        return (Log_entry (date, summary, items)))))


(* Parser TODO
 * - test edge cases (omitted, added parts, empty lines etc.)
 * - substitutions
 * - clean up block parser
 * …
 *)
let log_parser =
  (editor_comment <|> return ()) *>
  skip_many empty_line *>
  spaced_list log_entryp

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
