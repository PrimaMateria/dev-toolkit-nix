{root}: let
  inherit (root) packages;
in {
  packages = [
    packages.playdebug
    packages.playwright-browsers-1_47_0
  ];

  shellHook = ''
    # Prepare playwright
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    export PLAYWRIGHT_BROWSERS_PATH=${packages.playwright-browsers-1_47_0}
    export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
  '';
}
