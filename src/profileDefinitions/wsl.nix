{pkgs}: {
  hook = ''
    unset name
    export DISPLAY=:1
  '';
}
