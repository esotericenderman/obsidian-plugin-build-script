# Obsidian Plugin Build Script

[![Project status: maintained][status]][root]

A script to build the plugins inside a given Obsidian vault from their source code and move the built artifacts to their corresponding folders.

## Supported Plugin Types

This script should support *most* plugins, however if a plugin uses a custom build strategy or there is an intermediate build step, it may not yet be supported.

| Plugin build strategy             | Supported |
|-----------------------------------|:---------:|
| [esbuild][esbuild] (default)      | ✅         |
| [Yarn][yarn]                      | ✅         |
| [Obsidian Dev Utils][dev-utils]   | ✅         |
| [Excalidraw][excalidraw] (custom) | ✅         |

## Usage

Run the script with the following command:

```sh
./build_obsidian_plugins.sh "vault" "source"
```

### Parameters

- `vault`: The path to the root of your vault. This is the folder containing the `.obsidian` folder.
- `source`: The path from a plugin directory (`.obsidian/plugins/plugin`) to its source code.

## License

&copy; 2025 [Esoteric Enderman][author-website]

[Obsidian Plugin Build Script][root] is licensed under the [AGPL 3.0][license] only.

## Topics

<sup>bash script scripting scripts bash-script obsidian bash-scripting bash-scripts obsidian-plugin obsidian-md obsidian-vault obsidian-plugins obsidianmd obsidian-notes obsidian-script obsidian-plugin-development</sup>

<!-- Link aliases -->

[root]: /

[author-website]: https://enderman.dev

[status]: ./assets/images/badges/status.svg

<!-- References -->

[esbuild]: https://esbuild.github.io/
[yarn]: https://github.com/yarnpkg/berry
[dev-utils]: https://github.com/mnaoumov/obsidian-dev-utils
[excalidraw]: https://github.com/zsviczian/obsidian-excalidraw-plugin

<!-- Files -->

[license]: ../LICENSE
