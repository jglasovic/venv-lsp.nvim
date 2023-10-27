local lspconfig = require 'venv-lsp.lspconfig'
local M = {}

function M.init()
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

  M.initialized = true
end

return M
