{
  pkgs,
  root,
}: {npmScript ? "test:debug"}: let
  inherit (root) packages;
in {
  packages = [
    (packages.testdebug.override {inherit npmScript;})
  ];
  shellHook = ''
    # Jest debug logs
    export DEBUG_PRINT_LIMIT=5000000
  '';
}
