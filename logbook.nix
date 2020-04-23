{ buildDunePackage, ocaml_lwt, jingoo, ptime, angstrom, astring, cow}:

buildDunePackage rec {
  version = "0.2";
  pname = "logbook";

  src = ./.;

  buildInputs = [ cow ocaml_lwt jingoo ptime angstrom astring ];

  useDune2 = true;
}
