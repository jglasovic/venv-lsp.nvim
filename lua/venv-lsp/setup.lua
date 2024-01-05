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
  local venv_lspconfig = require 'venv-lsp.lspconfig'
  venv_lspconfig.init()

  M.initialized = true
end

function M.active_virtualenv()
  local virtualenv = vim.env.VIRTUAL_ENV
  if virtualenv then
    local _, _, venv_name = string.find(virtualenv, '[/\\]([^/\\]+)$')
    return venv_name or ''
  end
  return ''
end

return M
