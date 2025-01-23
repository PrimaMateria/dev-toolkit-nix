{
  description = "foo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    devToolkit.url = "github:primamateria/dev-toolkit-nix";
    # devToolkit.url = "/home/primamateria/dev/dev-toolkit-nix";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    utils,
    ...
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in
      with inputs.devToolkit.profiles.${system}; {
        devShell = inputs.devToolkit.lib.${system}.buildDevShell {
          name = "nix.shell.foo";
          profiles = [
            {name = "wsl";}
          ];
        };
      });
}
