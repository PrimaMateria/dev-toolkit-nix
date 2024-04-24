{pkgs}: (
  pkgs.writeShellApplication
  {
    name = "mockoon-join";
    runtimeInputs = [pkgs.jq];
    text = ''
      # Function to display help message
      show_help() {
          echo "Usage: $0 INPUT_DIR OUTPUT_FILE"
          echo "Description: This script updates a JSON file with route data by adding routes from individual JSON files in the specified input directory."
          echo "Arguments:"
          echo "  INPUT_DIR     Path to the directory containing JSON files with route data."
          echo "  OUTPUT_FILE   Path to the JSON file to be updated."
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

      inputdir=$1
      outputfile=$2

      # Create a backup of the original output file
      backupfile="''${outputfile}_orig"
      cp "$outputfile" "$backupfile"

      # Clear existing routes in the output file
      jq '.routes |= []' "$outputfile" > "''${outputfile}_tmp" && mv "''${outputfile}_tmp" "$outputfile"

      # Add routes from individual JSON files in the input directory
      for chunk in "$inputdir"/*; do
          echo "Adding $chunk"
          jq ".routes += [$(cat "$chunk")]" "$outputfile" > "''${outputfile}_tmp" && mv "''${outputfile}_tmp" "$outputfile"
      done
    '';
  }
)
