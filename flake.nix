{
  description = "Collection tools and utilities used in my development process";

  inputs = {
    nixpkgsPlaywright.url = "github:kalekseev/nixpkgs/playwright-core";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "/home/primamateria/dev/nixpkgs";
    utils.url = "github:numtide/flake-utils";

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgsPlaywright,
    utils,
    haumea,
    ...
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {allowUnfree = true;};
        };
        pkgsPlaywright = import nixpkgsPlaywright {
          inherit system;
          config = {allowUnfree = true;};
        };
      in (haumea.lib.load {
        src = ./src;
        inputs = {inherit pkgs pkgsPlaywright;};
      })
    );
}
