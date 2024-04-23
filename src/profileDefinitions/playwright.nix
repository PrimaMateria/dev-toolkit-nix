{
  pkgs,
  root,
}: let
  inherit (root) packages;
in {
  packages = [
    pkgs.playwright-driver.browsers
    packages.playdebug
  ];

  hook = ''
    # Prepare playwright
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
  '';
}
