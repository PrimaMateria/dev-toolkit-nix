{
  description = "foo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils.url = "github:numtide/flake-utils";
    devToolkit = {
      url = "github:primamateria/dev-toolkit-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # devToolkit = {
    #   url = "/home/primamateria/dev/dev-toolkit-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
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
            # {
            #   name = "node";
            #   options = {version = "20";};
            # }
          ];
        };
      });
}
