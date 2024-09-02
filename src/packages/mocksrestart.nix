{pkgs}: (
  pkgs.writeShellApplication
  {
    name = "mocksrestart";
    text = ''
      npx pm2 delete all && npm run mocks:start
    '';
  }
)
