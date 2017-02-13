#!/usr/bin/env ocaml
#use "topfind"
#require "topkg"
open Topkg

let () =
  Pkg.describe "logbook" @@ fun c ->
  Ok [ Pkg.mllib "src/log.mllib"; ]
