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
    pushd "$plugin" > /dev/null

    echo "Finding plugin source code"
    pushd "$plugin_source" > /dev/null

    echo "Installing dependencies"
    npm install

    case "${build_strategies[$name]}" in
        "excalidraw")
            echo "Using Excalidraw build strategy"

            pushd "./MathjaxToSVG" > /dev/null

            npm install
            npm run build

            popd > /dev/null

            npm run build
            ;;
        "obsidian-dev-utils")
            echo "Using Obsidian Dev Utils build strategy"
            npx obsidian-dev-utils build
            ;;
        "yarn")
            echo "Using yarn build strategy"
            npx yarn run build
            ;;
        *)
            echo "Using default build strategy"
            node esbuild.config.mjs production
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
            mv "$plugin_source/dist/main.js" ./
            mv "$plugin_source/dist/manifest.json" ./

            [[ -f "$plugin_source/dist/styles.css" ]] && mv "$plugin_source/dist/styles.css" ./
            ;;
        "obsidian-dev-utils")
            mv "$plugin_source/dist/build/main.js" ./
            mv "$plugin_source/dist/build/manifest.json" ./
            ;;
        *)
            mv "$plugin_source/main.js" ./
            cp "$plugin_source/manifest.json" ./

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
        git submodule foreach --recursive git restore ./
    fi
fi

popd > /dev/null

echo "Build process complete!"
