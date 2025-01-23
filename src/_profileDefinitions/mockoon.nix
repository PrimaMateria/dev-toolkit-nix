{
  pkgs,
  root,
}: {}: let
  inherit (root) packages;
in {
  packages = [
    packages.mockoon
    packages.mockoon-cut
    packages.mockoon-join
    packages.mocksrestart
  ];
}
