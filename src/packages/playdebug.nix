{pkgs}: (
  # Fzf runner for integration tests
  pkgs.writeShellApplication
  {
    name = "playdebug";
    runtimeInputs = [pkgs.fzf];
    text = ''
      TEMP_FILE="/tmp/testcase.txt"

      # Function to find testcase and save to temp file
      find_and_save_testcase() {
          TESTCASE=$(find src -name "*.int.test.ts*" | fzf)
          echo "$TESTCASE" > "$TEMP_FILE"
      }

      # Function to handle repeat branch
      repeat_testcase() {
          if [ -f "$TEMP_FILE" ]; then
              TESTCASE=$(< "$TEMP_FILE")
          else
              echo "Error: Temp file does not exist."
              exit 1
          fi
      }

      # Check if the script is called with any arguments
      if [ $# -gt 0 ]; then
          # Check if the first argument is -r or --repeat
          if [[ "$1" == "-r" || "$1" == "--repeat" ]]; then
              repeat_testcase
          else
              find_and_save_testcase
          fi
      else
          find_and_save_testcase
      fi

      # Run the test with the obtained testcase
      npm run test:int:debug -- "$TESTCASE"
    '';
  }
)
