# Obsidian Plugin Build Script

[![Project status: maintained][status]][root]

A script to build the plugins inside a given Obsidian vault from their source code and move the built artifacts to their corresponding folders.

> [!WARNING]
> This plugin will clean [git submodules][git-submodules] (if there are any), which may be considered destructive! Make sure to commit your changes before running.

## Information

- [Credit][credit]

## Requirements

- [jq][jq]

## Supported Plugin Types

This script should support *most* plugins, however if a plugin uses a custom build strategy or there is an intermediate build step, it may not yet be supported.

| Plugin build strategy                                         | Supported |
|---------------------------------------------------------------|:---------:|
| [esbuild][esbuild] ([default][default-esbuild-configuration]) |     ✅     |
| [Yarn][yarn]                                                  |     ✅     |
| [Obsidian Dev Utils][dev-utils]                               |     ✅     |
| [Excalidraw][excalidraw] (custom)                             |     ✅     |

## Usage

See [Esoteric Thought / Primitive Notions][example] for an example usage of this script.

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

<sup>[bash](https://github.com/topics/bash), [script](https://github.com/topics/script), [scripting](https://github.com/topics/scripting), [scripts](https://github.com/topics/scripts), [bash-script](https://github.com/topics/bash-script), [obsidian](https://github.com/topics/obsidian), [bash-scripting](https://github.com/topics/bash-scripting), [bash-scripts](https://github.com/topics/bash-scripts), [obsidian-plugin](https://github.com/topics/obsidian-plugin), [obsidian-md](https://github.com/topics/obsidian-md), [obsidian-vault](https://github.com/topics/obsidian-vault), [obsidian-plugins](https://github.com/topics/obsidian-plugins), [obsidianmd](https://github.com/topics/obsidianmd), [obsidian-notes](https://github.com/topics/obsidian-notes), [obsidian-script](https://github.com/topics/obsidian-script), [obsidian-plugin-development](https://github.com/topics/obsidian-plugin-development)</sup>

<!-- Link aliases -->

[root]: /

[author-website]: https://enderman.dev

[status]: ./assets/images/badges/status.svg

<!-- References -->

[esbuild]: https://esbuild.github.io/
[default-esbuild-configuration]: https://github.com/obsidianmd/obsidian-sample-plugin/blob/6d09ce3e39c4e48d756d83e7b51583676939a5a7/esbuild.config.mjs

[yarn]: https://github.com/yarnpkg/berry
[dev-utils]: https://github.com/mnaoumov/obsidian-dev-utils
[excalidraw]: https://github.com/zsviczian/obsidian-excalidraw-plugin

[example]: https://gitlab.com/esotericthought/primitive-notions

[git-submodules]: https://git-scm.com/book/en/v2/Git-Tools-Submodules

<!-- Dependencies -->

[jq]: https://jqlang.org/

<!-- Files -->

[license]: ../LICENSE
[credit]: ./CREDIT.md
