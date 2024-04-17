{pkgs}: {
  hook = ''
    unset name
    export DISPLAY=:1
    echo "wsl profile loaded"
  '';
}
