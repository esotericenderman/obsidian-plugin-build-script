#!/bin/bash

# A script to build the plugins inside a given Obsidian vault from their source code and move the built artifacts to their corresponding folders.

# Usage:
# build_obsidian_plugins.sh vault source
# vault: the path to the root of the vault (the folder that contains the .obsidian folder).
# source: the path from a plugin folder (.obsidian/plugins/plugin) to its source code.

set -e

vault="$1"
plugin_source="$2"

if [[ ! -f "$vault" ]]; then
    echo "Error: vault directory not found!"
    exit 1
fi

if [[ ! -f "$vault/.obsidian" ]]; then
    echo "Error: provided directory is not an Obsidian vault as it does not contain a .obsidian folder!"
    exit 2
fi

if [[ ! -f "$vault/.obsidian/plugins" ]]; then
    echo "Error: no plugins folder found in .obsidian directory!"
    exit 3
fi

if [ -z "$( ls -A "$vault/.obsidian/plugins" )" ]; then
   echo "No plugins found in plugins folder. Nothing to do."
   exit 0
fi

echo "Building plugins"
echo "Vault: $vault"
echo "Plugin source: $plugin_source"

pushd "$vault" > /dev/null

echo "Current working directory: $(pwd)"

declare -A build_strategies=(
    ["obsidian-filename-heading-sync"]="yarn"
    ["better-markdown-links"]="obsidian-dev-utils"
    ["obsidian-excalidraw-plugin"]="excalidraw"
)

build_plugin() {
    local plugin="$1"
    local name=$(basename "$plugin")

    echo "Building plugin: $name"
    pushd "$plugin" > /dev/null || { echo "Error: failed to enter directory $plugin!" ; exit 4 }

    echo "Finding plugin source code"
    pushd "$plugin_source" > /dev/null || { echo "Error: source code of plugin $plugin not found!"; exit 5 }

    echo "Installing dependencies"
    npm install || { echo "Error: failed to install dependencies of plugin $plugin!"; exit 6 }

    case "${build_strategies[$name]}" in
        "excalidraw")
            echo "Using Excalidraw build strategy"

            pushd "./MathjaxToSVG" > /dev/null || { echo "Error: failed to access Excalidraw sub-directory!"; exit 7 }

            npm install || { echo "Error: failed to install Excalidraw sub-directory dependencies!"; exit 6 }
            npm run build || { echo "Error: failed to install Excalidraw sub-project!"; exit 7 }

            popd > /dev/null

            npm run build || { echo "Error: failed to build Excalidraw!"; exit 7 }
            ;;
        "obsidian-dev-utils")
            echo "Using Obsidian Dev Utils build strategy"
            npx obsidian-dev-utils build || { echo "Error: failed to build plugin $plugin using Obsidian Dev Utils!"; exit 7 }
            ;;
        "yarn")
            echo "Using yarn build strategy"
            npx yarn run build || { echo "Error: failed to build plugin $plugin using Yarn!"; exit 7 }
            ;;
        *)
            echo "Using default build strategy"
            node esbuild.config.mjs production || { echo "Error: failed to build plugin $plugin using esbuild!"; exit 7 }
            ;;
    esac

    popd > /dev/null

    move_built_files "$name"

    popd > /dev/null
}

move_built_files() {
    local name="$1"
    echo "Moving built files for $name"

    case "${build_strategies[$name]}" in
        "excalidraw")
            mv "$plugin_source/dist/main.js" ./ || { echo "Error: failed to move Excalidraw main file!"; exit 8 }
            mv "$plugin_source/dist/manifest.json" ./ || { echo "Error: failed to move Excalidraw manifest file!"; exit 8 }

            [[ -f "$plugin_source/dist/styles.css" ]] && mv "$plugin_source/dist/styles.css" ./
            ;;
        "obsidian-dev-utils")
            mv "$plugin_source/dist/build/main.js" ./ || { echo "Error: failed to move main file of plugin $plugin built with Obsidian Dev Utils!"; exit 8 }
            mv "$plugin_source/dist/build/manifest.json" ./ || { echo "Error: failed to move manifest file of plugin $plugin built with Obsidian Dev Utils!"; exit 8 }
            ;;
        *)
            mv "$plugin_source/main.js" ./ || { echo "Error: failed to move main file of plugin $plugin!"; exit 8 }
            cp "$plugin_source/manifest.json" ./ || { echo "Error: failed to move manifest file of plugin $plugin!"; exit 8 }

            [[ -f "$plugin_source/styles.css" ]] && cp "$plugin_source/styles.css" ./
            ;;
    esac
}

for plugin in ./.obsidian/plugins/*/; do
    build_plugin "$plugin" || echo "Failed to build $plugin"
done

echo "Checking for Git repository and submodules"
if command -v git &> /dev/null && git rev-parse --is-inside-work-tree &> /dev/null; then
    if git submodule status &> /dev/null; then
        echo "Removing possible created lock files"
        git submodule foreach --recursive git restore ./ || { echo "Failed to restore submodules to their original state!"; exit 9 }
    fi
fi

popd > /dev/null

echo "Build process complete!"
