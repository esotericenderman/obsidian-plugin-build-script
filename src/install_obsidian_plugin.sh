pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null || exit 1

. ./build_obsidian_plugin.sh --source-only

popd >/dev/null || exit 1

install_obsidian_plugin() {
  local vault="$1"

  if [[ -z $vault ]]; then
    echo "Error: No Obsidian vault argument provided! Cannot install Obsidian plugin!"
    exit 2
  fi

  for plugin_source in "${@:2}"; do
    if [[ -z $plugin_source ]]; then
      echo "Error: No Obsidian plugin source code provided! Cannot install Obsidian plugin into vault at path $vault!"
      exit 2
    fi

    if [ ! -d "$vault" ]; then
      echo "Error: Obsidian vault at path $vault not found! Cannot install Obsidian plugin at path $plugin_source!"
      exit 3
    fi

    if [ ! -d "$plugin_source" ]; then
      echo "Error: Obsidian plugin source code at path $plugin_source not found! Cannot install into vault $vault!"
      exit 3
    fi

    local plugin_json
    plugin_json=$(cat "./$plugin_source/manifest.json") || {
      echo "Error: failed to read Obsidian plugin manifest.json file at path $plugin_source! Cannot install into vault $vault!"
      exit 4
    }

    local plugin_id
    plugin_id=$(echo "$plugin_json" | jq -r .id) || {
      echo "Error: failed to read Obsidian plugin ID from manifest.json file while install plugin at path $plugin_source into Obsidian vault at path $vault!"
      exit 4
    }

    if [[ -z $plugin_id ]]; then
      echo "Error: failed to read Obsidian plugin ID from manifest.json file while install plugin at path $plugin_source into Obsidian vault at path $vault!"
      exit 4
    fi

    build_obsidian_plugin "$plugin_source"

    echo "Installing Obsidian plugin with ID $plugin_id..."

    local plugin_directory="$vault/.obsidian/plugins/$plugin_id"

    mkdir -p plugin_directory || {
      echo "Error: failed to create Obsidian plugin directory $plugin_directory while installing Obsidian plugin $plugin_id into vault $vault!"
      exit 9
    }

    case "${obsidian_plugin_build_strategies[$plugin_id]}" in
    "excalidraw")
      mv "$plugin_source/dist/main.js" "$plugin_directory" || {
        echo "Error: failed to move Excalidraw main file!"
        exit 7
      }

      mv "$plugin_source/dist/manifest.json" "$plugin_directory" || {
        echo "Error: failed to move Excalidraw manifest file!"
        exit 7
      }

      [[ -f "$plugin_source/dist/styles.css" ]] && {
        mv "$plugin_source/dist/styles.css" "$plugin_directory" || {
          echo "Error: failed to move Excalidraw styles file!"
          exit 7
        }
      }
      ;;
    "obsidian-dev-utils")
      mv "$plugin_source/dist/build/main.js" "$plugin_directory" || {
        echo "Error: failed to move main file of plugin $plugin_id built with Obsidian Dev Utils!"
        exit 7
      }

      mv "$plugin_source/dist/build/manifest.json" "$plugin_directory" || {
        echo "Error: failed to move manifest file of plugin $plugin_id built with Obsidian Dev Utils!"
        exit 7
      }

      [[ -f "$plugin_source/dist/build/styles.css" ]] && {
        mv "$plugin_source/dist/build/styles.css" "$plugin_directory" || {
          echo "Error: failed to move styles file of plugin $plugin_id built with Obsidian Dev Utils!"
          exit 7
        }
      }
      ;;
    *)
      mv "$plugin_source/main.js" "$plugin_directory" || {
        echo "Error: failed to move main file of plugin $plugin_id!"
        exit 7
      }

      cp "$plugin_source/manifest.json" "$plugin_directory" || {
        echo "Error: failed to move manifest file of plugin $plugin_id!"
        exit 7
      }

      [[ -f "$plugin_source/styles.css" ]] && {
        cp "$plugin_source/styles.css" "$plugin_directory" || {
          echo "Error: failed to move styles file of plugin $plugin_id!"
          exit 7
        }
      }
      ;;
    esac
  done
}

if [ "$1" != --source-only ]; then
  install_obsidian_plugin "$@"
fi
