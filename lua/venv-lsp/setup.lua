local lspconfig = require 'venv-lsp.lspconfig'
local null_ls = require 'venv-lsp.null_ls'
local config = require 'venv-lsp.config'

local M = {}

function M.init(opts)
  if opts.activate_global then
    config.activate_global()
  end

  if M.initialized then
    return
  end

  local success_lsp_config, _ = pcall(require, 'lspconfig')
  if not success_lsp_config then
    vim.notify(
      string.format(
        '[venv-lsp] Missing "lspconfig"!'),
      vim.log.levels.WARN
    )
    return
  end
  lspconfig.init()

  local success_null_ls, _ = pcall(require, 'null-ls')
  if success_null_ls and not config.activate_global then
    null_ls.init()
  end

  M.initialized = true
end

return { init = M.init }
