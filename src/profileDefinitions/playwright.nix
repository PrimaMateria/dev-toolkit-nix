{
  pkgs,
  root,
}: let
  inherit (root) packages;

  playwright-driver = pkgs.playwright-driver.overrideAttrs (finalAttrs: previousAttrs: {
    version = "1.43.0";
  });
in {
  packages = [
    playwright-driver.browsers
    packages.playdebug
  ];

  shellHook = ''
    # Prepare playwright
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    export PLAYWRIGHT_BROWSERS_PATH=${playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
  '';
}
