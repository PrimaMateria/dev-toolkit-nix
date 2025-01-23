{
  pkgs,
  root,
}: {}: let
  inherit (root) packages;
in {
  packages = with packages; [
    clang
    clang-tools
    cmake
  ];
}
