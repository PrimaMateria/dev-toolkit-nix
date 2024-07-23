{
  pkgs,
  root,
}: let
  inherit (root) packages secrets;

  awsConfig = pkgs.writeText "awsConfig" ''
    [default]
    ${(pkgs.lib.traceVal secrets.default).awsSsoConfig}
  '';
in {
  packages = [
    pkgs.awscli2
  ];

  shellHook = ''
    export AWS_CONFIG_FILE=${awsConfig}
  '';
}
