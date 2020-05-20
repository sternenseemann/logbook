(*---------------------------------------------------------------------------
   Copyright (c) 2017 sternenseemann. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
   %%NAME%% %%VERSION%%
  ---------------------------------------------------------------------------*)

(** OCaml representation and parsing of the
    {{:https://github.com/sternenseemann/logbook#the-log-format}log format}.

    {e %%VERSION%% — {{:%%PKG_HOMEPAGE%% }homepage}} *)

(** {1 Log} *)

(** {2 Log Representation} *)

(** Describes, how private a log item is, where private means
    “item only visible to oneself, semi-private “item visible to trusted persons”
    and public “item visible to everyone”. *)
type privacy_level = Private | Semi_private | Public

(** A log item consisting of its privacy level, a title and a text, both in markup ['a].  *)
type 'a item = Item of privacy_level * 'a * 'a

(** A log entry consisting of a date, a summary and items, both in markup ['a]. *)
type 'a log_entry = Log_entry of Ptime.date * 'a * ('a item) list

(** A log file consisting of multiple log entries for multiple days using markup ['a]. *)
type 'a log = ('a log_entry) list

(** A test to check wether a privacy level of e. g. an item is
    compatible with the (maximum) privacy level available. *)
val compatible_privacy : privacy_level -> privacy_level -> bool

(** Get the corresponding privacy level for a char *)
val privacy_level_of_char : char -> privacy_level option

(** Remove all items incompatible with the given privacy level
    from the list of items. *)
val filter_privacy_level : privacy_level -> ('a item) list -> ('a item) list

(** {2 Log Parsing} 

    log files are parsed using {{:https://github.com/inhabitedtype/angstrom}angstrom}.
*)

(** An angstrom parser for log files *)
val log_parser : (string log) Angstrom.t

(** {2 Log processing} *)

(** Convert a log's markup. This is especially useful
    to apply a specific markup to a freshly parsed log file. *)
val apply_markup : ('a -> 'b) -> 'a log -> 'b log

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
