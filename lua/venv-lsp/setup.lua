local commands = require('venv-lsp.commands')
local config = require('venv-lsp.config')
local cache = require('venv-lsp.cache')
local logger = require('venv-lsp.common.logger')

local M = {}

---@param user_config table|nil
---@return nil
function M.setup(user_config)
  if M.initialized then
    return
  end
  -- update default config
  if user_config then
    config.update(user_config)
  end
  -- setup cache
  cache.init()

  local nvim_v0_11 = vim.fn.has('nvim-0.11') == 1

  if nvim_v0_11 then
    require('venv-lsp.native_lsp').setup()
  end

  local success_lsp_config, _ = pcall(require, 'lspconfig')
  if not success_lsp_config and not nvim_v0_11 then
    logger.error('Missing required `lspconfig`!')
    return
  end

  if success_lsp_config then
    require('venv-lsp.lspconfig').setup()
  end
  commands.init_user_cmd()
  M.initialized = true
end

return M
