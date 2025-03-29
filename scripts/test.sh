#!/bin/bash
# Runs the build plugins script on the test vault.

pushd "$(dirname "${BASH_SOURCE[0]}")"/.. > /dev/null

. ./src/install_obsidian_plugins.sh --source-only

install_obsidian_plugins test source

popd > /dev/null
