logbook — tool for personal log files
-------------------------------------------------------------------------------
%%VERSION%%

logbook is TODO

logbook is distributed under the ISC license.

Homepage: https://sternen.space/ocaml/logbook  

## Installation

logbook can be installed with `opam`:

    opam install logbook

If you don't use `opam` consult the [`opam`](opam) file for build
instructions.

## Documentation

The documentation and API reference is generated from the source
interfaces. It can be consulted [online][doc] or via `odig doc
logbook`.

[doc]: https://sternen.space/logbook/doc

## Sample programs

If you installed logbook with `opam` sample programs are located in
the directory `opam var logbook:doc`.

In the distribution sample programs and tests are located in the
[`test`](test) directory of the distribution. They can be built and run
with:

    topkg build --tests true && topkg test 
