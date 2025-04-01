{
  pkgs,
  root,
}: {playwrightVersion ? "1.47.0"}: let
  inherit (root) packages;

  browserPackageVersion = builtins.replaceStrings ["."] ["_"] playwrightVersion;
  browserPackageName = "playwright-browsers-${browserPackageVersion}";
  browserPackage =
    if packages ? "${browserPackageName}"
    then builtins.getAttr browserPackageName packages
    else throw "Package ${browserPackageName} not found for the Playwright version ${playwrightVersion}.";
in {
  packages = [
    packages.playdebug
    packages.playwright-browsers-1_46_1
    packages.playwright-browsers-1_47_0
    packages.playwright-browsers-1_48_2
    packages.playwright-browsers-1_51_1
  ];

  shellHook = ''
    # Prepare playwright
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    export PLAYWRIGHT_BROWSERS_PATH=${browserPackage}
    export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
  '';
}
