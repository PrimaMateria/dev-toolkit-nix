{
  description = "Collection tools and utilities used in my development process";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs@{ self, nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };

        # NPM wrapper that passes user config stored in nix store. To avoid
        # name collision, it is named just `f` (the home key of index finger).
        npmWrapper = pkgs.writeShellApplication
          {
            name = "npm";
            text = ''
              ${pkgs.nodejs-18_x}/bin/npm --userconfig ${npmrc} "$@"
            '';
          };

        # The nix store is not writable, therefore we must instruct npm to
        # use different folder for the global packages,
        npmrc = pkgs.writeText "npmrc" ''
          prefix=~/.npm-global
          @finapi-internal:registry=https://repo.finapi.io/artifactory/api/npm/npm/

          # Place following to the project's .npmrc
          # init-author-name=<name>
          # email=<email>
          # //registry.npmjs.org/:_authToken=<authToken>
          # //repo.finapi.io/artifactory/api/npm/npm/:_auth="<authToken>"
        '';

        shellHookBase = pkgs.writeShellApplication {
          name = "shellHookBase";
          text = ''
            unset name
            export DISPLAY=:1
          '';
        };

        shellHookNpm = pkgs.writeShellApplication {
          name = "shellHookNpm";
          text = ''
            if [ ! -d "$HOME/.npm-global" ]; then
              mkdir "$HOME/.npm-global"
              echo "Created ~/.npm-global"
            fi

            export PATH="$HOME/.npm-global/bin:$PATH"
          '';
        };

      in
      {
        packages = {
          inherit shellHookBase;
          inherit shellHookNpm npmWrapper;
        };
      });
}
