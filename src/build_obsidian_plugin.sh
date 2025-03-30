#!/bin/bash

pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null || exit 1

. ./obsidian_plugin_build_strategies.sh

popd >/dev/null || exit 1

build_obsidian_plugin() {
  for plugin_source in "$@"; do
    if [[ -z "$plugin_source" ]]; then
      echo "Error: no Obsidian plugin source code provided! Can't build Obsidian plugin."
      exit 2
    fi

    echo "Building Obsidian plugin at path: $plugin_source"

    if [ ! -d "$plugin_source" ]; then
      echo "Error: Obsidian plugin source code at path $plugin_source not found!"
      exit 3
    fi

    pushd "$plugin_source" >/dev/null || {
      echo "Error: failed to enter Obsidian plugin source code folder at path $plugin_source!"
      exit 1
    }

    if [ ! -f ./manifest.json ]; then
      echo "Obsidian plugin manifest.json file not found at path $plugin_source!"
      exit 3
    fi

    local plugin_json
    plugin_json=$(cat ./manifest.json) || {
      echo "Error: failed to read Obsidian plugin manifest.json file at path $plugin_source!"
      exit 4
    }

    local plugin_id
    plugin_id=$(echo "$plugin_json" | jq -r .id) || {
      echo "Error: failed to read Obsidian plugin ID from manifest.json file when building plugin at path $plugin_source!"
      exit 4
    }

    if [[ -z $plugin_id ]]; then
      echo "Error: failed to read Obsidian plugin ID from manifest.json file while building Obsidian plugin at path $plugin_source!"
      exit 4
    fi

    echo "Building Obsidian plugin with ID $plugin_id..."

    echo "Installing dependencies"

    pwd

    npm install || {
      echo "Error: failed to install dependencies of Obsidian plugin $plugin_id!"
      exit 5
    }

    local build_strategy=${obsidian_plugin_build_strategies[$plugin_id]}

    if [[ -z $build_strategy ]]; then
      echo "No custom build strategy identified"
    else
      echo "Custom build strategy identified: $build_strategy"
    fi

    case $build_strategy in
    "excalidraw")
      echo "Using Excalidraw Obsidian plugin build strategy"

      pushd "./MathjaxToSVG" >/dev/null || {
        echo "Error: failed to access Obsidian $plugin_id sub-directory!"
        exit 1
      }

      npm install || {
        echo "Error: failed to install Obsidian plugin $plugin_id sub-directory dependencies!"
        exit 5
      }

      npm run build || {
        echo "Error: failed to install Obsidian plugin $plugin_id sub-project!"
        exit 6
      }

      popd >/dev/null || exit

      npm run build || {
        echo "Error: failed to build Obsidian plugin $plugin_id!"
        exit 6
      }
      ;;
    "obsidian-dev-utils")
      echo "Using Obsidian Dev Utils build strategy"

      npx obsidian-dev-utils build || {
        echo "Error: failed to build Obsidian plugin $plugin_id using Obsidian Dev Utils!"
        exit 6
      }
      ;;
    "yarn")
      echo "Using Yarn Obsidian plugin build strategy"

      npx yarn run build || {
        echo "Error: failed to build Obsidian plugin $plugin_id using Yarn!"
        exit 6
      }
      ;;
    *)
      echo "Using default Obsidian plugin build strategy"

      node esbuild.config.mjs production || {
        echo "Error: failed to build Obsidian plugin $plugin_id using esbuild!"
        exit 6
      }
      ;;
    esac

    popd >/dev/null || exit 1
  done
}

if [ "$1" != --source-only ]; then
  build_obsidian_plugin "$@"
fi
