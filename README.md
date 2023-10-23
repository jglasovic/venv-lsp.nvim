# venv-lsp.nvim
A small wrapper around [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) that automatically handles python virtualenvs

## Usage
The easiest way to use this plugin is to call `init` method before any `lspconfig` setup

```lua
local venv_lsp = require 'venv-lsp'
venv_lsp.init()
-- source/setup lspconfig after
local lspconfig = require 'lspconfig'
```

## How it works
There are plugins like [poet-v](https://github.com/petobens/poet-v), [vim-virtualenv](https://github.com/jmcantrell/vim-virtualenv), [vim-pipenv](https://github.com/PieterjanMontens/vim-pipenv)
that automatically detects and activates venv globally, this plugin DOESN'T do that.
Instead, it just sets it for the LSP process. This works nicely for the monorepo projects that have multiple
virtualenvs where different parts of the project belong to a different venv. Jumping between buffers in such
monorepo where LSP detects different root dir by patterns and spawns process can have issues with plugins above if the LSP process starts before the new venv is activated globally. 
That would require `:LspRestart` to properly start the process with the new venv activated.
This plugin ensures that the LSP process has the right virtualenv activated just for that process.

`lspconfig` has a hook called `on_new_config` that triggers anytime it detects another root dir by patterns. This plugin injects its own `on_new_config`.
It is going to be injected only for those LSPs that has support for the `python` filetype and are explicitly setup.
For example:
```lua
lspconfig.pyright.setup(...)
```
It is going to inject it just for `pyright` and nothing else.
Also, it will not interfere with another explicitly added `on_new_config` to the setup
```lua
lspconfig.pyright.setup({ 
    on_new_config = function(new_config, new_dir_path) 
        -- user's custom config modifications
        end
    })
```

Injected `on_new_config` tries to detect if the virtualenv for the `new_dir_path` exists, if it does, it is going to provide `cwd_env` to the `new_config` with two new values for the process.
It sets `VIRTUAL_ENV` env var and it prepends `PATH` env var with the detected virtualenv path. That way the LSP process is going to have activated venv.
Also, it will not interfere with the user's custom `cwd_env` if provided.





