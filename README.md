# venv-lsp.nvim

A Neovim plugin for automatic Python virtual environment detection and activation, seamlessly integrating with Neovim's built-in LSP client and popular Python language servers.

![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)
![Neovim 0.8+](https://img.shields.io/badge/neovim-0.8+-green.svg)

## Requirements

- **Neovim** 0.8 or newer (Zero-config for 0.11+)
- **Python** 3.7+
- For Neovim < 0.11: [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) is required
- At least one supported Python language server (`pyright`, `basedpyright`, or `pyrefly`) must be installed
- For automatic venv detection: at least one supported Python venv manager (`poetry` or `pyenv`)
  *(Alternatively, you can manually set root dir and venv path mappings via command — no supported venv manager required for manual venv setup.)*

## Features

- **Automatic virtualenv detection:** Finds and activates the correct Python virtual environment for each project or buffer.
- **Zero config for Neovim 0.11+:** No need for `lspconfig` — uses the new `vim.lsp.config` API.
- **LSP integration:** Works with `pyright`, `basedpyright`, and `pyrefly`.
- **Per-buffer venv activation:** Ensures each buffer uses the correct Python interpreter.
- **Cache for fast switching:** Remembers venvs per root directory for quick activation.
- **Extensible:** Designed to support more venv managers and LSPs (currently supports `poetry` and `pyenv`).

## Installation

Use your favorite plugin manager. 

#### lazy.nvim

Example with `lazy.nvim`:

```lua
{
  "jglasovic/venv-lsp.nvim",
  config = function()
    require("venv-lsp").setup()
  end,
}
```

#### vim-plug

Example with `vim-plug`:
```vim
Plug 'jglasovic/venv-lsp.nvim'
```
After installing, add the following to your Neovim config:
```lua
require("venv-lsp").setup()
```

## Quick Start

For Neovim 0.11 and newer:
***No need for `lspconfig` — uses the new built-in LSP configuration API.***

```lua
require("venv-lsp").setup()

-- Don't forget to enable your Python language server
vim.lsp.enable('pyright')
```


Your Python LSPs (e.g., `pyright`) will automatically use the correct virtualenv.

For Neovim < 0.11:

```lua
require("venv-lsp").setup()
local lspconfig = require("lspconfig")
lspconfig.pyright.setup({})
```

*With Neovim < 0.11 and using `lspconfig`, make sure to call `require("venv-lsp").setup()` before calling `lspconfig.pyright.setup({})`.*

## Usage

### Manual LSP Configuration

If you need to configure any of the supported Python language servers manually, do so before calling `require("venv-lsp").setup()`:

```lua
vim.lsp.config('pyright', { root_markers = {'.git'} })
require("venv-lsp").setup()
```

`venv-lsp` will respect all custom configuration passed before calling `setup()`.

### Commands

The following user commands are provided by `venv-lsp`:

- `:VenvLspAddVenv`  
  Prompt to add a virtual environment mapping for a project root.

- `:VenvLspRemoveVenv`  
  Prompt to remove a virtual environment mapping.

- `:VenvLspCacheDisable`  
  Disable the virtual environment cache.

- `:VenvLspCacheEnable`  
  Enable the virtual environment cache.

- `:VenvLspAutoDisable`  
  Disable automatic virtual environment detection.

- `:VenvLspAutoEnable`  
  Enable automatic virtual environment detection.

- `:VenvLspCacheFile`  
  Open the cache file in the editor.


## Configuration

You can pass a config table to `setup()` to customize behavior:

```lua
require("venv-lsp").setup({
  cache_json_path = vim.fn.stdpath('cache') .. '/venv_lsp/cache.json', -- (default) Custom path for venv cache file
  disable_cache = false, -- (default) Set to true to disable reading/writing cached venv in json file (still uses in-memory cache)
  disable_auto_venv = false, -- (default) Set to true to disable automatic venv detection
})
```

- `disable_auto_venv`: (boolean) If true, disables automatic virtual environment detection and activation.  
  Default: `false`
- `disable_cache`: (boolean) If true, disables reading/writing cached venvs in the JSON file (still uses in-memory cache).  
  Default: `false`
- `cache_json_path`: (string) Path to the JSON file used for caching venv locations per project.  
  Default: `vim.fn.stdpath('cache') .. '/venv_lsp/cache.json'`

## How it works

There are plugins like [poet-v](https://github.com/petobens/poet-v), [vim-virtualenv](https://github.com/jmcantrell/vim-virtualenv), [vim-pipenv](https://github.com/PieterjanMontens/vim-pipenv) (which inspired this plugin) that automatically detect and activate a virtualenv for the current buffer.  
The problem with those plugins is that if the LSP process starts before the right virtual environment is activated, the Python executable for that process is not the one from the activated virtual environment.

This plugin uses 3 hooks to work:

| Neovim v0.11 and newer      | Neovim < 0.11 and lspconfig     |
|-----------------------------|---------------------------------|
| root_dir                    | root_dir                        |
| before_init                 | on_new_config                   |
| on_attach                   | on_attach                       |

- `root_dir`: First checks if the buffer belongs to any of the known (cached) venvs, if not, falls back to the default/provided `root_dir` implementation (root_markers) for detecting venv root dir.
- `before_init`/`on_new_config`: Checks cache for venv with root dir value, if not found, tries to detect it for that root. When found, it caches the venv and activates it.
- `on_attach`: Sets venv value to the buffer's local var for easier activation on jumps between buffers.

This plugin works well for monorepo projects that have multiple virtualenvs, where different parts of the project belong to different venvs.  
Jumping between buffers in such a monorepo where LSP detects different root dirs will not produce issues like those mentioned above.

## Supported LSPs

- pyright
- basedpyright
- pyrefly

*Planned: jedi-language-server, pylsp, pylyzer (see TODO)*

## Supported Virtualenv Managers

- poetry
- pyenv

*Planned: pipenv (see TODO)*

## Troubleshooting

- **Venv not detected?**  
  Make sure your project uses a supported venv manager and that the venv is created.
- **LSP not using the correct Python?**  
  Ensure you have followed the setup order described above for your Neovim version.
- **Want to force a venv for a project?**  
  Use `:VenvLspAddVenv` to manually add a venv for your project.

*If you don't want to bother with venv auto detection, you can always add `<root_dir>:<venv_path>` mappings via the `:VenvLspAddVenv` command. The plugin will respect that value and work for all subdirectory Python files with that venv.*

## FAQ

**Q: How do I use a custom virtual environment for a project?**  
A: Use `:VenvLspAddVenv` and follow the prompts to enter your root directory and venv path.  
Alternatively, you can manually add mappings to the cache JSON file if you prefer.

**Q: Can I use this with a venv manager other than poetry or pyenv?**  
A: Yes! You can manually map `<root_dir>` to venv path using `:VenvLspAddVenv`, or by editing the cache JSON file directly. The plugin will activate the venv accordingly.

**Q: Does this work with monorepos?**  
A: Yes! Each buffer uses the correct venv based on its root directory.

## Contributing

Contributions, issues, and feature requests are welcome!  
Feel free to [open an issue](https://github.com/jglasovic/venv-lsp.nvim/issues) or submit a pull request.

## License

MIT License

## TODO

- [ ] Add venv search as in [vscode-python](https://github.com/microsoft/vscode-python/tree/2faa16417084e4b3f9a448127f361dcb336d3ce6/src/client/pythonEnvironments/common/environmentManagers)
- [ ] fzf.vim, fzf-lua, telescope.nvim support for venv search
- [ ] Support for `jedi-language-server`
- [ ] Support for `pylsp`
- [ ] Support for `pylyzer`
