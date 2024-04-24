{pkgs}: (
  pkgs.writeShellApplication
  {
    name = "mockoon-cut";
    runtimeInputs = [pkgs.jq];
    text = ''
      # Function to display help message
      show_help() {
          echo "Usage: $0 INPUT_FILE OUTPUT_DIR"
          echo "Description: This script processes routes from a JSON file and saves them as individual JSON files in the specified output directory."
          echo "Arguments:"
          echo "  INPUT_FILE    Path to the input JSON file containing routes."
          echo "  OUTPUT_DIR    Path to the output directory where JSON files will be saved."
          echo "Options:"
          echo "  -h, --help    Show this help message."
      }

      # Check for help option
      if [[ "$1" == "-h" || "$1" == "--help" ]]; then
          show_help
          exit 0
      fi

      # Check for required arguments
      if [ "$#" -ne 2 ]; then
          echo "Error: Invalid number of arguments. Use -h or --help for usage instructions."
          exit 1
      fi

      inputfile=$1
      outputdir=$2

      # Remove existing output directory if it exists, then create a new one
      rm -rf "$outputdir" || true
      mkdir -p "$outputdir"

      # Process routes from input JSON file
      routes=$(jq -c '.routes[]' "$inputfile")

      while IFS= read -r route; do
          method=$(echo "$route" | jq -c '.method' | sed 's/"//g' )
          endpoint=$(echo "$route" | jq -c '.endpoint' | tr / _  | sed 's/"//g')
          echo "$route" | jq . > "$outputdir/$endpoint.$method.json"
      done <<< "$routes"
    '';
  }
)
