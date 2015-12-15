sysPkgs: import (sysPkgs.fetchgit {
    url    = git://github.com/ryantrinkle/try-reflex;
    # ghcjs-improved-base-2:
    rev    = "8854b2f46f4262d003bb2d6daf59d74d72772d53";
    sha256 = "1177a27d19f276376b5b77a3b491642b1462e44e5cbd669b2e36a7a784da066f";
    # old-base:
    # rev    = "70a7230df219d604e25caf22c22c7a5553c30af4";
    # sha256 = "b0b95ff5d578230578d2a42163c8577a1aaac71528da30bea075ade4fce548fb";
  }) {}
