{
  pkgsPlaywright,
  root,
}: let
  inherit (root) packages;
in {
  packages = [
    pkgsPlaywright.playwright-driver.browsers
    packages.playdebug
  ];

  shellHook = ''
    # Prepare playwright
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    export PLAYWRIGHT_BROWSERS_PATH=${pkgsPlaywright.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
  '';
}
