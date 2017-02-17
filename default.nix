let pkgs = import <nixpkgs> {};
in pkgs.ocamlPackages_4_02.callPackage ./logbook.nix {}
