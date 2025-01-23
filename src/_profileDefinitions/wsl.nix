{pkgs}: {}: {
  shellHook = ''
    unset name
    export DISPLAY=:1
  '';
}
