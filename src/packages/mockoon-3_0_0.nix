# Mockoon provides mocked backend APIs for local development and
# integration tests. The version of the app should match the version
# of the Mockoon CLI, which is used to start the environment
# headlessly. The latest versions of the main app and CLI are in sync,
# but for older versions, the version mapping can be found in the
# release notes: https://mockoon.com/old-releases/cli/.
{pkgs}: (
  let
    pname = "mockoon";
    version = "3.0.0";
    src =
      pkgs.fetchurl
      {
        url = "https://github.com/mockoon/mockoon/releases/download/v3.0.0/mockoon-3.0.0.AppImage";
        sha256 = "sha256-YGcD/8h21fUoBEAcBVI5jo0UMCKdVRdC1zxDIrHjU+8=";
      };
    appimageContents =
      pkgs.appimageTools.extractType2
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
