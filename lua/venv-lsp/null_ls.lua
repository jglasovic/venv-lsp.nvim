local venv = require 'venv-lsp.venv'
local util = require 'venv-lsp.util'

local M = {}

function M._env(env)
  return function(opts)
    if type(env) == "function" then
      env = env(opts)
    end
    local virtualenv_path = venv.LRU or venv.get_virtualenv_path(opts.cwd)
    return venv.set_virtualenv_tbl(env, virtualenv_path)
  end
end

function M._with(with)
  return function(opts)
    opts.env = M._env(opts.env)
    return with(opts)
  end
end

function M._modify_config(config)
  local filetypes = vim.tbl_get(config, 'filetypes')
  if not filetypes or not util.list_contains(filetypes, 'python') then
    return config
  end
  config.with = M._with(config.with)
  return config.with({})
end

function M.init()
  local null_ls = require 'null-ls'
  util.modify_metatable(null_ls.builtins.diagnostics, M._modify_config)
  util.modify_metatable(null_ls.builtins.formatting, M._modify_config)
end

return M
