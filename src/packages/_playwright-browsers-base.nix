# https://github.com/pietdevries94/playwright-web-flake
{pkgs}: {
  version,
  sha256,
}: let
  fontconfig = pkgs.makeFontsConf {fontDirectories = [];};

  chromiumDir =
    if pkgs.lib.versionAtLeast version "1.58.0"
    then "chrome-linux64"
    else "chrome-linux";

  headlessShellDir =
    if pkgs.lib.versionAtLeast version "1.58.0"
    then "chrome-headless-shell-linux64"
    else "chrome-linux";

  headlessShellBin =
    if pkgs.lib.versionAtLeast version "1.58.0"
    then "chrome-headless-shell"
    else "headless_shell";

  playwright-browsers-json = pkgs.stdenv.mkDerivation rec {
    name = "playwright-${version}-browsers";
    src = pkgs.fetchFromGitHub {
      owner = "Microsoft";
      repo = "playwright";
      rev = "v${version}";
      sha256 = sha256;
    };
    installPhase = ''
      mkdir -p $out
      cp packages/playwright-core/browsers.json $out/browsers.json
    '';
  };
in
  pkgs.runCommand "playwright-browsers-chromium"
  {
    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.jq
    ];
  }
  ''
    BROWSERS_JSON=${playwright-browsers-json}/browsers.json
    CHROMIUM_REVISION=$(jq -r '.browsers[] | select(.name == "chromium").revision' $BROWSERS_JSON)
    mkdir -p $out/chromium-$CHROMIUM_REVISION/${chromiumDir}

    # See here for the Chrome options:
    # https://github.com/NixOS/nixpkgs/issues/136207#issuecomment-908637738
    makeWrapper ${pkgs.chromium}/bin/chromium $out/chromium-$CHROMIUM_REVISION/${chromiumDir}/chrome \
      --set SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt \
      --set FONTCONFIG_FILE ${fontconfig}

    # We also need to install the headless shell version of Chromium
    CHROMIUM_HEADLESS_SHELL_REVISION=$(jq -r '.browsers[] | select(.name == "chromium-headless-shell").revision' $BROWSERS_JSON)
    mkdir -p $out/chromium_headless_shell-$CHROMIUM_HEADLESS_SHELL_REVISION/${headlessShellDir}

    # See here for the Chrome options:
    # https://github.com/NixOS/nixpkgs/issues/136207#issuecomment-908637738
    makeWrapper ${pkgs.chromium}/bin/chromium $out/chromium_headless_shell-$CHROMIUM_HEADLESS_SHELL_REVISION/${headlessShellDir}/${headlessShellBin} \
       --set SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt \
       --set FONTCONFIG_FILE ${fontconfig}

    FFMPEG_REVISION=$(jq -r '.browsers[] | select(.name == "ffmpeg").revision' $BROWSERS_JSON)
    mkdir -p $out/ffmpeg-$FFMPEG_REVISION
    ln -s ${pkgs.ffmpeg}/bin/ffmpeg $out/ffmpeg-$FFMPEG_REVISION/ffmpeg-linux
  ''
