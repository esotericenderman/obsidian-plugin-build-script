pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null

. ./obsidian_plugin_build_strategies.sh

popd > /dev/null

install_obsidian_plugin() {
    local vault="$1"
    local plugin_source="$2"

    if [[ -z $vault ]]; then
        echo "Error: No Obsidian vault argument provided! Cannot install Obsidian plugin!"; exit 1
    fi

    if [[ -z $plugin_source ]]; then
        echo "Error: No Obsidian plugin source code provided! Cannot install Obsidian plugin into vault at path $vault!"; exit 2
    fi

    if [ ! -d "$vault" ]; then
      echo "Error: Obsidian vault at path $vault not found! Cannot install Obsidian plugin at path $plugin_source!"; exit 3
    fi

    if [ ! -d "$plugin_source" ]; then
      echo "Error: Obsidian plugin source code at path $plugin_source not found! Cannot install into vault $vault!"; exit 4
    fi

    local plugin_json=$(cat ./$plugin_source/manifest.json) || {
        echo "Error: failed to read Obsidian plugin manifest.json file at path $plugin_source! Cannot install into vault $vault!"; exit 5
    }

    local plugin_id=$(echo $plugin_json | jq -r .id) || {
        echo "Error: failed to read Obsidian plugin ID from manifest.json file while install plugin at path $plugin_source into Obsidian vault at path $vault!"; exit 6
    }

    if [[ -z $plugin_id ]]; then
        echo "Error: failed to read Obsidian plugin ID from manifest.json file while install plugin at path $plugin_source into Obsidian vault at path $vault!"; exit 6
    fi

    echo "Installing Obsidian plugin with ID $plugin_id..."

    local plugin_directory="$vault/.obsidian/plugins/$plugin_id"

    case "${obsidian_plugin_build_strategies[$plugin_id]}" in
        "excalidraw")
            mv "$plugin_source/dist/main.js" $plugin_directory || {
              echo "Error: failed to move Excalidraw main file!"; exit 7
            }

            mv "$plugin_source/dist/manifest.json" $plugin_directory || {
              echo "Error: failed to move Excalidraw manifest file!"; exit 7
            }

            [[ -f "$plugin_source/dist/styles.css" ]] && mv "$plugin_source/dist/styles.css" $plugin_directory
            ;;
        "obsidian-dev-utils")
            mv "$plugin_source/dist/build/main.js" $plugin_directory || {
              echo "Error: failed to move main file of plugin $plugin built with Obsidian Dev Utils!"; exit 8
            }

            mv "$plugin_source/dist/build/manifest.json" $plugin_directory || {
              echo "Error: failed to move manifest file of plugin $plugin built with Obsidian Dev Utils!"; exit 8
            }
            ;;
        *)
            mv "$plugin_source/main.js" $plugin_directory || {
              echo "Error: failed to move main file of plugin $plugin!"; exit 8
            }

            cp "$plugin_source/manifest.json" $plugin_directory || {
              echo "Error: failed to move manifest file of plugin $plugin!"; exit 8
            }

            [[ -f "$plugin_source/styles.css" ]] && cp "$plugin/$plugin_source/styles.css" $plugin_directory
            ;;
    esac
}

if [ $1 != --source-only ]; then
    install_obsidian_plugin $@
fi
