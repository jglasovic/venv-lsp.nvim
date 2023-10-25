local util = require 'venv-lsp.util'
local venv = require 'venv-lsp.venv'
local config = require 'venv-lsp.config'

local M = {}

function M._on_new_config(on_new_config)
  return function(new_config, root_dir)
    if on_new_config then
      on_new_config(new_config, root_dir)
    end
    if config.activate_global then
      venv.deactivate_virtualenv()
    end
    local virtualenv_path = venv.get_virtualenv_path(root_dir)
    print('on_new_config')
    print(vim.inspect(virtualenv_path))
    if config.activate_global then
      venv.activate_virtualenv(virtualenv_path)
    else
      new_config.cmd_env = venv.set_virtualenv_tbl(new_config.cmd_env, virtualenv_path)
    end
  end
end

function M._on_attach(on_attach)
  return function(client, bufnr)
    print('on_attach')
    print(bufnr)
    if on_attach then
      on_attach(client, bufnr)
    end
  end
end
function M._setup(setup)
  return function(opts)
    if not opts then
      opts = {}
    end
    opts.on_new_config = M._on_new_config(opts.on_new_config)
    opts.on_attach = M._on_attach(opts.on_attach)
    return setup(opts)
  end
end

function M._modify_config(opts)
  local filetypes = vim.tbl_get(opts, 'document_config', 'default_config', 'filetypes')
  if not filetypes or not util.list_contains(filetypes, 'python') then
    return opts
  end
  opts.setup = M._setup(opts.setup)
  return opts
end

function M.init()
  local lspconfig = require 'lspconfig'
  return util.modify_metatable(lspconfig, M._modify_config)
end

return M
