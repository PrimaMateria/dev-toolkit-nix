# TODO: AppImage removed from GitHub, either build or migrate to newer mockoon in WF
{pkgs}: (
  let
    pname = "mockoon";
    version = "1.19.0";
    src = pkgs.fetchurl {
      url = "https://github.com/mockoon/mockoon/releases/download/v1.19.0/mockoon-1.19.0.AppImage";
      sha256 = "sha256-nfNa+zBDanMBMpJJg4+7g0+cWM2qOaweh+dFCpGKbEI=";
    };
    appimageContents = pkgs.appimageTools.extractType2 {
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
