# venv-lsp.nvim
Automatically handles python virtualenvs with [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)  
*NOTE: Currently supports `pyright` lsp with `poetry` virtual environments*

## Usage
The easiest way to use this plugin is to call `init` method before any `lspconfig` setup

```lua
local venv_lsp = require 'venv-lsp'
venv_lsp.init()
-- source/setup lspconfig after
local lspconfig = require 'lspconfig'
```

## How it works
There are plugins like [poet-v](https://github.com/petobens/poet-v), [vim-virtualenv](https://github.com/jmcantrell/vim-virtualenv), [vim-pipenv](https://github.com/PieterjanMontens/vim-pipenv) (which are inspiration for this plugin)
that automatically detects and activates virtualenv for the current buffer.  
The problem with those plugins is that if the LSP process has started before the right virtualenv is activated, python executable for that process is not the one from the activated virtual environment.  
To fix that it requires manual process restart (:LspRestart)  
This plugin uses `on_new_config` lspconfig hook to detect and activate virtualenv before the buffer is attached to the LSP client, providing the right Python path to the LSP.  
The plugin works nicely for the monorepo projects that have multiple virtualenvs where different parts of the project belong to a different venv.  
Jumping between buffers in such monorepo where LSP detects different root dir by patterns (workspace) is not going to produce issues like with the mentioned plugins above.

## TODO
 - [ ] Support `pipenv` venvs
 - [ ] Support `pyenv` venvs
 - [ ] Support for `jedi-language-server` 
 - [ ] Support for `pylsp` 
 - [ ] Support for `pylyzer` 
