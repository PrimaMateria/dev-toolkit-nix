{
  pkgs,
  root,
}: {}: let
  inherit (root) packages;
in {
  packages = [
    packages.testdebug
  ];
  shellHook = ''
    # Jest debug logs
    export DEBUG_PRINT_LIMIT=5000000
  '';
}
