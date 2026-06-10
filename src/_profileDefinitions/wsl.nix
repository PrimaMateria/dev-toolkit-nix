{root}: {}: let
  inherit (root) packages;
in {
  shellHook = ''
    unset name
    export DISPLAY=:1
  '';
  packages = [
    packages.tags
  ];
}
