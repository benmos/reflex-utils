# Run with eg:
#
# NIX_PATH="nixpkgs=/path/to/my/nixpkgs" nix-build build.nix
#
{ pkgs ? import <nixpkgs> {} }:
let hp = pkgs.haskellPackages.override {
           overrides = self: super: {
             this = self.callPackage ./. {};
           };
         };
in hp.this

