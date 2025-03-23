#!/bin/bash

# A script to build the plugins inside a given Obsidian vault from their source code and move the built artifacts to their corresponding folders.

# Usage:
# build_obsidian_plugins.sh vault source
# vault: the path to the root of the vault (the folder that contains the .obsidian folder).
# source: the path from a plugin folder (.obsidian/plugins/plugin) to its source code.

set -e

vault_path="$1"
plugin_source="$2"

echo "Building plugins"
echo "Vault: $vault_path"
echo "Plugin source: $plugin_source"

if [[ ! -d "$vault_path" ]]; then
    echo "Error: Vault directory '$vault_path' not found!"
    exit 1
fi

pushd "$vault_path" > /dev/null

echo "Current working directory: $(pwd)"

declare -A build_strategies=(
    ["obsidian-excalidraw-plugin"]="excalidraw"
    ["better-markdown-links"]="obsidian-dev-utils"
    ["obsidian-filename-heading-sync"]="yarn"
)

build_plugin() {
    local plugin_dir="$1"
    local plugin_name
    plugin_name=$(basename "$plugin_dir")

    echo "Building plugin: $plugin_name"
    pushd "$plugin_dir" > /dev/null

    echo "Finding plugin source code"
    pushd "$plugin_source" > /dev/null

    echo "Installing dependencies"
    npm install

    case "${build_strategies[$plugin_name]}" in
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
            echo "Using normal build strategy"
            node esbuild.config.mjs production
            ;;
    esac

    popd > /dev/null

    move_built_files "$plugin_name"

    popd > /dev/null
}

move_built_files() {
    local plugin_name="$1"
    echo "Moving built files for $plugin_name"

    case "${build_strategies[$plugin_name]}" in
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

for plugin_dir in ./.obsidian/plugins/*/; do
    build_plugin "$plugin_dir" || echo "Failed to build $plugin_dir"
done

echo "Removing possible created lock files"
git submodule foreach --recursive git restore .

popd > /dev/null

echo "Build process complete!"
