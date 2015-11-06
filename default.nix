{ mkDerivation, stdenv
, these
}:
mkDerivation {
  pname        = "reflex-utils";
  version      = "0.0";
  src          = builtins.filterSource (path: type:
                                        let base   = baseNameOf path;
                                            prefix = builtins.substring 0 1 base;
                                            suffix = builtins.substring (builtins.stringLength base - 1) 1 base;
                                        in
                                        prefix != "." && suffix != "#" && suffix != "~" &&        # Blacklist
                                        (stdenv.lib.hasPrefix (toString ./src) (toString path) || # Whitelist
                                         builtins.elem base ["reflex-utils.cabal" "Setup.hs" "LICENSE"]))
                                  ./.;
  buildDepends = [
    these
  ];
  testDepends = [
  ];
  license = null;
}
