# This is runner for old integration test written in jest.
{pkgs}: (
  pkgs.writeShellApplication
  {
    name = "intdebug";
    runtimeInputs = [pkgs.fzf];
    text = ''
      TARGET=$(find src -name "*.int.test.ts*" | fzf)
      npm run test -- "$TARGET"
    '';
  }
)
