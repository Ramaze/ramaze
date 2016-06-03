with (import /home/manveru/github/nixos/nixpkgs {});
let
  env = bundlerEnv {
    name = "ramaze";
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
    gemspec = ./ramaze.gemspec;
    groups = [];
  };
in stdenv.mkDerivation {
  name = "ramaze";
  buildInputs = [
    env env.ruby env.bundler
    # ruby bundler
  ];
}
