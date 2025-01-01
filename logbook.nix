{ buildDunePackage, ocaml_lwt, jingoo, ptime, angstrom, astring, cow, odoc }:

buildDunePackage rec {
  version = "0.3";
  pname = "logbook";

  duneVersion = "3";

  src = ./.;

  nativeBuildInputs = [ odoc ];
  buildInputs = [ cow ocaml_lwt jingoo ];
  propagatedBuildInputs = [ ptime angstrom astring ];
}
