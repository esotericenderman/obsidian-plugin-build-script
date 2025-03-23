#!/bin/bash
#
# Builds the Obsidian plugins inside a given vault from their source code and moves the built artifacts to their corresponding folder.
# Usage:
# ./build_obsidian_plugins.sh ./path/to/vault/folder ./path/from/plugin/to/source
# Argument 1: the path to the root of the vault. (the folder that contains the .obsidian folder)
# Argument 2: the path from the plugin folder (.obsidian/plugins/plugin) to its source code.

echo Building plugins

echo Vault: $1
echo Plugin source: $2

cd $1 || exit 1

echo Current working directory:
pwd

echo Updating submodules

git submodule update --init --recursive

excalidraw_folder_name="obsidian-excalidraw-plugin"
better_markdown_links_folder_name="better-markdown-links"
filename_heading_sync_folder_name="obsidian-filename-heading-sync"

for d in ./.obsidian/plugins/*/ ;
    do (
        echo Building plugin $d

        cd $d || exit 2

        echo Current working directory:
        pwd

        echo Finding plugin source code

        cd $2 || exit 3

        echo Current working directory:
        pwd

        echo Installing dependencies

        npm i || exit 4

        if [ $d == "./plugin-repositories/$excalidraw_folder_name/" ]; then
            echo Using Excalidraw build strategy

            (
                cd ./MathjaxToSVG

                npm i || exit 4
                npm run build || exit 5
            );

            npm run build || exit 5
        elif [ $d == "./plugin-repositories/$better_markdown_links_folder_name/" ]; then
            echo Using Obsidian Dev Utils build strategy
            npx obsidian-dev-utils build || exit 5
        elif [ $d == "./plugin-repositories/$filename_heading_sync_folder_name/" ]; then
            echo Using yarn build strategy
            npx yarn run build || exit 5
        else
            echo Using normal build strategy
            node esbuild.config.mjs production || exit 5
        fi

        cd - || exit 6

        echo Making sure directories exist

        echo Current working directory:
        pwd

        if [ $d == "./plugin-repositories/$excalidraw_folder_name/" ]; then
            echo Using dist folder movement strategy

            mv ${d}/dist/main.js ./plugins/${p}main.js || exit 7
            mv ${d}/dist/manifest.json ./plugins/${p}manifest.json || exit 7
            mv ${d}/dist/styles.css ./plugins/${p}styles.css || exit 7
        elif [ $d == "./plugin-repositories/$better_markdown_links_folder_name/" ]; then
            echo Using dist/build folder movement strategy

            mv ${d}/dist/build/main.js ./plugins/${p}main.js || exit 7
            mv ${d}/dist/build/manifest.json ./plugins/${p}manifest.json || exit 7
        else
            echo Using standard movement strategy

            mv ${d}main.js ./plugins/${p}main.js || exit 7
            cp ${d}manifest.json ./plugins/${p}manifest.json || exit 7
            cp ${d}styles.css ./plugins/${p}styles.css || exit 7
        fi
    );
done

echo Current working directory:
pwd

echo Removing possible created lock files

git submodule foreach git restore ./ || exit 8
