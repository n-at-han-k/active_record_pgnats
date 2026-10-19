{
  description = "Active Record migrations for pgnats";

  inputs = {
    nixpkgs.url = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
    mine.url = "github:n-at-han-k/flake.nix";
    mine.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, mine, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = mine.lib.${system};

        # railties pulls actionpack, which pulls nokogiri, whose source gem
        # wants a full libxml2 build. Take the precompiled gem for this system
        # instead -- bundix records one platform's hash under the plain version,
        # which never matches whatever the builder then fetches.
        nokogiriPlatforms = {
          x86_64-linux = {
            platform = "x86_64-linux-gnu";
            sha256 = "0sm0h74pnjfxl1y2mzdy5wmysrc4rwnwwlnp34zmx4981d2ax7rp";
          };
          aarch64-linux = {
            platform = "aarch64-linux-gnu";
            sha256 = "13qsqdvwdnykaja86ks2lwyb828j5dv5rpakg82hbr3d99jgns8j";
          };
          x86_64-darwin = {
            platform = "x86_64-darwin";
            sha256 = "0l85yw2c4iwhb7cpwfr3xyjx9lwmcpbkqjx7ajchxw71sdbp1lbz";
          };
          aarch64-darwin = {
            platform = "arm64-darwin";
            sha256 = "09rmsqfzkipxi4zyp0wm54xcynni2ww9bipb6rxmkrl66a2vjvd4";
          };
        };

        gemset = import ./gemset.nix;

        nokogiriGem =
          let
            selected = nokogiriPlatforms.${system} or (throw
              "nokogiri has no precompiled gem for ${system}");
            generic = gemset.nokogiri;
          in
          generic // {
            version = "${generic.version}-${selected.platform}";
            source = generic.source // { sha256 = selected.sha256; };
          };

        gems = pkgs.bundlerEnv {
          name = "active-record-pgnats-gems";
          ruby = pkgs.ruby_3_4;
          gemfile = ./Gemfile;
          lockfile = ./Gemfile.lock;
          gemset = gemset // { nokogiri = nokogiriGem; };
        };
      in
      {
        devShells.default = lib.mkRubyShell {
          buildInputs = with pkgs; [
            gems
            gems.wrappedRuby
            postgresql_17
            trufflehog
          ];

          shellHook = /* bash */ ''
            export BUNDLE_FORCE_RUBY_PLATFORM=false
            export BUNDLE_GEMFILE="$PWD/Gemfile"
            export BUNDLE_FROZEN=false

            export LANG="''${LANG:-C.UTF-8}"
            export LC_ALL="''${LC_ALL:-$LANG}"

            # Neither gem is in the bundle; both are this tree.
            export RUBYLIB="$PWD/lib''${RUBYLIB:+:$RUBYLIB}"

            if [ ! -f .git/hooks/pre-commit ]; then
              bundle exec lefthook install
            fi
          '';
        };
      }
    );
}
