# Obsidian Plugin Build Script

[![Project status: maintained][status]][root]

A script to build the plugins inside a given Obsidian vault from their source code and move the built artifacts to their corresponding folders.

## Supported Plugin Types

This script should support *most* plugins, however if a plugin uses a custom build strategy or there is an intermediate build step, it may not yet be supported.

| Plugin build strategy             | Supported |
|-----------------------------------|-----------|
| [esbuild][esbuild] (default)      | ✅         |
| [Yarn][yarn]                      | ✅         |
| [Obsidian Dev Utils][dev-utils]   | ✅         |
| [Excalidraw][excalidraw] (custom) | ✅         |

## Topics

<sup>bash script scripting scripts bash-script obsidian bash-scripting bash-scripts obsidian-plugin obsidian-md obsidian-vault obsidian-plugins obsidianmd obsidian-notes obsidian-script obsidian-plugin-development</sup>

<!-- Link aliases -->

[root]: /

[status]: ./assets/images/badges/status.svg

<!-- References -->

[esbuild]: https://esbuild.github.io/
[yarn]: https://github.com/yarnpkg/berry
[dev-utils]: https://github.com/mnaoumov/obsidian-dev-utils
[excalidraw]: https://github.com/zsviczian/obsidian-excalidraw-plugin
