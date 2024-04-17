{
  pkgs,
  root,
}: let
  inherit (root) packages;
in {
  packages = [
    packages.mockoon-1_19_0
  ];
}
