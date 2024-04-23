{
  pkgs,
  root,
}: let
  inherit (root) packages;
in {
  packages = [
    packages.testdebug
  ];
  hook = ''
    # Jest debug logs
    export DEBUG_PRINT_LIMIT=5000000
  '';
}
