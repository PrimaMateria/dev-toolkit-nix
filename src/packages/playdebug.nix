{pkgs}:
# Fzf runner for integration tests
pkgs.writeShellApplication {
  name = "playdebug";
  runtimeInputs = [pkgs.fzf];
  text = ''
    TEMP_FILE="/tmp/testcase.txt"
    no_debug=false
    repeat=false

    # Determine the test type from the environment variable or default to "int"
    PLAYDEBUG_TEST_TYPE=''${PLAYDEBUG_TEST_TYPE:-int}
    echo "$PLAYDEBUG_TEST_TYPE"

    # Function to find testcase and save to temp file
    find_and_save_testcase() {
        TESTCASE=$(find src -name "*.$PLAYDEBUG_TEST_TYPE.test.ts*" | fzf)
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

    # Parse command-line options
    while getopts ":rx" opt; do
        case $opt in
            r)
                repeat=true
                ;;
            x)
                no_debug=true
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    # Check if any arguments are left after parsing options
    if [ $# -gt 0 ]; then
        echo "Error: Unexpected argument(s) provided."
        exit 1
    fi

    # If repeat is set
    if $repeat; then
        repeat_testcase
    else
        find_and_save_testcase
    fi

    # Determine which test command to run based on the presence of the --noDebug flag
    if $no_debug; then
        npm run test:"$PLAYDEBUG_TEST_TYPE":run -- --retries 0 "$TESTCASE"
    else
        npm run test:"$PLAYDEBUG_TEST_TYPE":debug -- --retries 0 "$TESTCASE"
    fi
  '';
}
