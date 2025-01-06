#!/bin/bash
#
# Regenerate README with list of actions and their description.

PWD="$(dirname "$(readlink -f "$0")")"
REPO_ROOT="$(realpath "$PWD/../../")"

echo "| Name⠀⠀⠀⠀⠀⠀⠀⠀| Description |" >> tmp.md
echo "|---------------|-------------|" >> tmp.md

for dir in "$REPO_ROOT"/*; do
    if [ ! -d "$dir" ]; then
        continue
    fi

    action_name="$(basename "$dir")"
    action_description="n/a"

    if [ -f "$dir/action.yml" ]; then
        action_description="$(yq '.description' "$dir/action.yml" | tr '\n' ' ')"
    fi
    if [ -f "$dir/_action.yml" ]; then
        action_description="$(yq '.description' "$dir/_action.yml" | tr '\n' ' ')"
    fi

    echo "| \`$action_name\` | $action_description |" >> tmp.md
done

start_token="<!-- AUTO_GENERATE_START -->"
end_token="<!-- AUTO_GENERATE_END -->"

sed -i -ne '/'"$start_token"'/ {p; r tmp.md' -e ':a; n; /'"$end_token"'/ {p; b}; ba}; p' "$REPO_ROOT/README.md"

rm -f tmp.md
