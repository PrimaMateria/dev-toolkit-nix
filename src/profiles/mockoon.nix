{
  pkgs,
  root,
}: let
  inherit (root) packages;
in {
  packages = [
    packages.mockoon-3_0_0
  ];
}
