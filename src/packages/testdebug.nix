{pkgs}: (
  # The testdebug is a convenient runner for the unit tests. It starts
  # fzf, which allows for fuzzy-finding the desired unit. After the
  # selection, it runs jest in watch mode for that specific file and
  # also sets the coverage to be collected from that file.
  pkgs.writeShellApplication
  {
    name = "testdebug";
    runtimeInputs = [pkgs.fzf];
    text = ''
      TARGET=$(find src -name "*.ts*"  -and -not -path '**/__test*__/**' -and -not -path '**/openapi/**'  | fzf)
      TARGETPATH="''${TARGET%/*}"
      COMPONENT=''${TARGET##*/}
      COMPONENT=''${COMPONENT%.tsx}
      COMPONENT=''${COMPONENT%.ts}
      TESTCASE="$TARGETPATH/__test__/$COMPONENT.unit.test.ts"

      npm run test:unit:debug -- --coverage --collectCoverageFrom "$TARGET" "$TESTCASE"
    '';
  }
)
