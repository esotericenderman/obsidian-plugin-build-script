#!/bin/bash
# Runs the build plugins script on the test vault.

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"/..

original_directory=$(pwd)
test_directory=test

. ./build_obsidian_plugins.sh --source-only

for d in ./test/.obsidian/plugins/*/ ; do
    build_obsidian_plugin $d source
    install_obsidian_plugin $d source
done

cd -
