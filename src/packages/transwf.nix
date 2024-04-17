# Script that will update translation files with google-translated
# english value to target locale. Input is JSON jq path.
{pkgs}: (
  pkgs.writeShellApplication
  {
    name = "transwf";
    runtimeInputs = [pkgs.translate-shell pkgs.jq];
    text = ''
      JSON_PATH=$1
      LOCALES=( "cs" "de" "es" "fr" "it" "nl" "pl" "ro" "sk" "tr" )

      get_translation () {
        locale=$1
        translation=$(find ./src -path "**/$locale/translation.json")
        echo "$translation"
      }

      translation_en=$(get_translation "en")
      value_en=$(jq -r "$JSON_PATH" "$translation_en")
      echo "en = $value_en"

      for locale in "''${LOCALES[@]}"; do
        translation=$(get_translation "$locale")
        value=$(trans -b -t "$locale" "$value_en")
        echo "$locale = $value"
        jq "$JSON_PATH = \"$value\"" "$translation" > temp.json && mv temp.json "$translation"
      done
    '';
  }
)
