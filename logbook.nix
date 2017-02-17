{ stdenv, ocaml, topkg, ocamlbuild, findlib, ocaml_lwt
, jingoo, ptime, angstrom, astring, opam}:

stdenv.mkDerivation rec {
  version = "0.1";
  name = "ocaml${ocaml.version}-logbook-${version}";

  src = ./.;

  buildInputs = [ ocaml findlib ocamlbuild topkg opam
                  ocaml_lwt jingoo ptime angstrom astring
                ];

  inherit (topkg) buildPhase installPhase;
}
