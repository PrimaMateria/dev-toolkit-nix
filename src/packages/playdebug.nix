{pkgs}:
# Fzf runner for integration tests
pkgs.writeShellApplication {
  name = "playdebug";
  runtimeInputs = [pkgs.fzf];
  text = ''
    TEMP_FILE="/tmp/testcase.txt"
    no_debug=false
    repeat=false
    filename_pattern=""

    # Determine the test type from the environment variable or default to "int"
    PLAYDEBUG_TEST_TYPE=''${PLAYDEBUG_TEST_TYPE:-int}
    echo "$PLAYDEBUG_TEST_TYPE"

    # Function to find testcase and save to temp file
    find_and_save_testcase() {
        path_pattern=$1
        if [ -n "$path_pattern" ]; then
            TESTCASE=$(find src -path "*$path_pattern*.$PLAYDEBUG_TEST_TYPE.test.ts*" | fzf)
            echo "$TESTCASE" > "$TEMP_FILE"
        else
            TESTCASE=$(find src -name "*.$PLAYDEBUG_TEST_TYPE.test.ts*" | fzf)
            echo "$TESTCASE" > "$TEMP_FILE"
        fi
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
    show_help() {
        echo "Usage: playdebug [options]"
        echo
        echo "Options:"
        echo "  -r            Repeat the last test case"
        echo "  -x            Run without debugging"
        echo "  -f PATTERN    Filter test cases by path pattern"
        echo "  -h, --help    Display this help message"
    }

    while getopts ":rxf:h" opt; do
        case $opt in
            r)
                repeat=true
                ;;
            x)
                no_debug=true
                ;;
            f)
                filename_pattern="$OPTARG"
                ;;
            h)
                show_help
                exit 0
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    if [ $# -gt 0 ]; then
        echo "Error: Too many arguments provided."
        exit 1
    fi

    # If repeat is set
    if $repeat; then
        repeat_testcase
    else
        find_and_save_testcase "$filename_pattern"
    fi

    # Determine which test command to run based on the presence of the --noDebug flag
    if $no_debug; then
        npm run test:"$PLAYDEBUG_TEST_TYPE":run -- --retries 0 "$TESTCASE"
    else
        npm run test:"$PLAYDEBUG_TEST_TYPE":debug -- --retries 0 "$TESTCASE"
    fi
  '';
}
