local venv = require 'venv-lsp.venv'
local cache = require 'venv-lsp.cache'
local logger = require 'venv-lsp.logger'
local config = require 'venv-lsp.config'

local M = {
  _autocmd_venv_init = false,
  _usercmd_init = false
}

M.init_user_cmd = function()
  if M._usercmd_init then
    return
  end

  vim.api.nvim_create_user_command(
    'VenvLspAutoDisable',
    function()
      config.set_disabled_auto_venv(true)
      logger.info('Auto VIRTUAL_ENV detection is disabled!')
    end,
    { nargs = 0 }
  )

  vim.api.nvim_create_user_command(
    'VenvLspAutoEnable',
    function()
      config.set_disabled_auto_venv(false)
      logger.info('Auto VIRTUAL_ENV detection is enabled!')
    end,
    { nargs = 0 }
  )

  vim.api.nvim_create_user_command(
    'VenvLspAddVenv',
    cache.add_venv,
    { nargs = 0 }
  )
  vim.api.nvim_create_user_command(
    'VenvLspRemoveVenv',
    cache.remove_venv,
    { nargs = 0 }
  )

  vim.api.nvim_create_user_command(
    'VenvLspCacheFile',
    function()
      local config_dict = config.get()
      vim.cmd.edit(config_dict.cache_json_path)
    end,
    { nargs = 0 }
  )

  M._usercmd_added = true
end


function M.init_auto_venv()
  if M._autocmd_venv_init then
    return
  end
  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('VenvLsp', { clear = true }),
    pattern = { "*.py" },
    callback = function()
      local config_dict = config.get()
      if config_dict.disabled_auto_venv then
        return
      end
      venv.activate_buffer()
    end,
  })
  M._autocmd_venv_init = true
end

return M
