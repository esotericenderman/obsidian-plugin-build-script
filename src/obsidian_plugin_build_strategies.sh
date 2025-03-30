#!/bin/bash

declare -Ar obsidian_plugin_build_strategies=(
    ["obsidian-filename-heading-sync"]="yarn"
    ["better-markdown-links"]="obsidian-dev-utils"
    ["obsidian-excalidraw-plugin"]="excalidraw"
)

export obsidian_plugin_build_strategies
