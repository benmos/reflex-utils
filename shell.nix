# Run with eg:
#
# NIX_PATH="nixpkgs=/path/to/my/nixpkgs" nix-shell
#
{ pkgs ? import <nixpkgs> {} }:
 let this = import ./build.nix { inherit pkgs; }; in
 pkgs.lib.overrideDerivation this.env (attrs: {
   buildInputs = attrs.buildInputs ++
                 [ pkgs.haskellPackages.cabal-install ];
 })
