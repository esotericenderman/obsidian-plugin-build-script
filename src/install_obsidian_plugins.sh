#!/bin/bash

# A script to build the plugins inside a given Obsidian vault from their source code and move the built artifacts to their corresponding folders.

# Usage:
# build_obsidian_plugins.sh vault source
# vault: the path to the root of the vault (the folder that contains the .obsidian folder).
# source: the path from a plugin folder (.obsidian/plugins/plugin) to its source code.

pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null || exit

. ./install_obsidian_plugin.sh --source-only

popd > /dev/null || exit

install_obsidian_plugins() {
    local vault="$1"
    local plugin_source="$2"

    if [ ! -d "$vault" ] ; then
        echo "Error: Obsidian vault directory $vault not found!"; exit 1
    fi

    if [ ! -d "$vault/.obsidian" ] ; then
        echo "Error: provided directory is not an Obsidian vault as it does not contain a .obsidian folder!"; exit 2
    fi

    if ! test -d "$vault/.obsidian/plugins" ; then
        echo "Error: no plugins folder found in .obsidian directory!"; exit 3
    fi

    if [ -z "$( ls -A "$vault/.obsidian/plugins" )" ]; then
      echo "No plugins found in plugins folder. Nothing to do."; exit 0
    fi

    echo "Building plugins"
    echo "Vault: $vault"
    echo "Plugin source: $plugin_source"

    echo "Current working directory: $(pwd)"

    for plugin in ./$vault/.obsidian/plugins/*/; do
        echo "Running install script for Obsidian vault at path $vault..."
        echo "Running install script for Obsidian plugin $plugin..."
        echo "Relative source directory: $plugin_source"

        source_directory="$plugin/$plugin_source"

        echo "Obsidian plugin source is located at path $source_directory"

        install_obsidian_plugin "$vault" "$source_directory"
    done

    echo "Checking for Git repository and submodules"
    if command -v git &> /dev/null && git rev-parse --is-inside-work-tree &> /dev/null; then
        if git submodule status &> /dev/null; then
            echo "Removing possible created lock files"

            git submodule foreach --recursive "git restore ./ && git clean -f" || {
              echo "Failed to restore submodules to their original state!"; exit 9
            }
        fi
    fi

    echo "Build process complete!"
}

if [ "${1}" != "--source-only" ]; then
    install_obsidian_plugins "${@}"
fi
