{ buildDunePackage, ocaml_lwt, jingoo, ptime, angstrom, astring, cow, odoc }:

buildDunePackage rec {
  version = "0.3";
  pname = "logbook";

  src = ./.;

  nativeBuildInputs = [ odoc ];
  buildInputs = [ cow ocaml_lwt jingoo ];
  propagatedBuildInputs = [ ptime angstrom astring ];

  postBuild = "dune build @doc";
  postInstall = "cp -r _build/default/_doc/_html $out/doc/logbook/html";

  useDune2 = true;
}
