#!/bin/bash
# Runs the build plugins script on the test vault.

set -e

cd "$(dirname "$0")"

../build_obsidian_plugins.sh test source

cd -
