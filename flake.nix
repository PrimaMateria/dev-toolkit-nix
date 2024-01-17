{
  description = "Collection tools and utilities used in my development process";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs@{ self, nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };

        profiles = {
          wsl = {
            hook = ''
              unset name
              export DISPLAY=:1
              echo "wsl profile loaded"
            '';
          };

          node = {
            packages = with pkgs; [
              (
                let
                  npmrc =
                    # The nix store is not writable, therefore we must instruct npm to
                    # use different folder for the global packages,
                    pkgs.writeText "npmrc" ''
                      prefix=~/.npm-global
                      @finapi-internal:registry=https://repo.finapi.io/artifactory/api/npm/npm/

                      # Place following to the project's .npmrc
                      # init-author-name=<name>
                      # email=<email>
                      # //registry.npmjs.org/:_authToken=<authToken>
                      # //repo.finapi.io/artifactory/api/npm/npm/:_auth="<authToken>"
                    '';
                in
                # NPM wrapper that passes user config stored in nix store. To avoid
                  # name collision, it is named just `f` (the home key of index finger).
                pkgs.writeShellApplication
                  {
                    name = "npm";
                    text = ''
                      ${pkgs.nodejs-18_x}/bin/npm --userconfig ${npmrc} "$@"
                    '';
                  }
              )
              nodejs-18_x
            ];

            hook = ''
              if [ ! -d "$HOME/.npm-global" ]; then
                mkdir "$HOME/.npm-global"
                echo "Created ~/.npm-global"
              fi

              export PATH="$HOME/.npm-global/bin:$PATH"
            '';
          };

          playwright = {
            packages = with pkgs; [
              playwright-driver.browsers
              (
                # Fzf runner for integration tests
                pkgs.writeShellApplication
                  {
                    name = "playdebug";
                    runtimeInputs = [ pkgs.fzf ];
                    text = ''
                      TESTCASE=$(find src -name "*.int.test.ts*" | fzf)
                      npm run test:int:debug -- "$TESTCASE"
                    '';
                  })
            ];

            hook = ''
              # Prepare playwright
              export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
              export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
              export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
              echo "playwright profile loaded"
            '';
          };

          jest = {
            packages = [
              (
                # The testdebug is a convenient runner for the unit tests. It starts
                # fzf, which allows for fuzzy-finding the desired unit. After the
                # selection, it runs jest in watch mode for that specific file and
                # also sets the coverage to be collected from that file.
                pkgs.writeShellApplication
                  {
                    name = "testdebug";
                    runtimeInputs = [ pkgs.fzf ];
                    text = ''
                      TARGET=$(find src -name "*.ts*"  -and -not -path '**/__test*__/**' -and -not -path '**/openapi/**'  | fzf)
                      TARGETPATH="''${TARGET%/*}"
                      COMPONENT=''${TARGET##*/}
                      COMPONENT=''${COMPONENT%.tsx}
                      COMPONENT=''${COMPONENT%.ts}
                      TESTCASE="$TARGETPATH/__test__/$COMPONENT.unit.test.ts"

                      npm run test:unit:debug -- --coverage --collectCoverageFrom "$TARGET" "$TESTCASE"
                    '';
                  })
            ];
            hook = ''
              # Jest debug logs
              export DEBUG_PRINT_LIMIT=5000000
              echo "jest profile loaded"
            '';
          };

          mockoon = {
            packages = [
              # Mockoon provides mocked backend APIs for local development and
              # integration tests. The version of the app should match the version
              # of the Mockoon CLI, which is used to start the environment
              # headlessly. The latest versions of the main app and CLI are in sync,
              # but for older versions, the version mapping can be found in the
              # release notes: https://mockoon.com/old-releases/cli/.
              (
                let
                  pname = "mockoon";
                  version = "3.0.0";
                  src = pkgs.fetchurl
                    {
                      url =
                        "https://github.com/mockoon/mockoon/releases/download/v3.0.0/mockoon-3.0.0.AppImage";
                      sha256 = "sha256-YGcD/8h21fUoBEAcBVI5jo0UMCKdVRdC1zxDIrHjU+8=";
                    };
                  appimageContents = pkgs.appimageTools.extractType2
                    {
                      inherit pname version src;
                    };
                in
                pkgs.appimageTools.wrapType2
                  {
                    inherit pname version src;
                    extraInstallCommands = ''
                      mv $out/bin/${pname}-${version} $out/bin/${pname}

                      install -Dm 444 ${appimageContents}/${pname}.desktop -t $out/share/applications
                      cp -r ${appimageContents}/usr/share/icons $out/share

                      substituteInPlace $out/share/applications/${pname}.desktop \
                        --replace 'Exec=AppRun' 'Exec=${pname}'
                    '';
                  }
              )
            ];
          };
        };
      in
      {
        inherit profiles;
      });
}
