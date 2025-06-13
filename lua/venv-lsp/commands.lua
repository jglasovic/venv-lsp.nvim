local venv = require 'venv-lsp.venv'
local cache = require 'venv-lsp.cache'

local M = {
  -- By default auto venv detection is active
  disabled_auto_venv = false,
  --
  _autocmd_venv_added = false,
  _usercmd_added = false
}

M.init_user_cmd = function()
  if M._usercmd_added then
    return
  end

  vim.api.nvim_create_user_command(
    'VenvLspAutoDisable',
    function()
      M.disabled_auto_venv = true
      print('Auto VIRTUAL_ENV detection is disabled!')
    end,
    { nargs = 0 }
  )

  vim.api.nvim_create_user_command(
    'VenvLspAutoEnable',
    function()
      M.disabled_auto_venv = false
      print('Auto VIRTUAL_ENV detection is enabled!')
    end,
    { nargs = 0 }
  )

  vim.api.nvim_create_user_command(
    'VenvLspRemapRootDir',
    cache.add_root_dir,
    { nargs = 0 }
  )
  vim.api.nvim_create_user_command(
    'VenvLspRemoveRootDirRemap',
    cache.remove_root_dir,
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

  M._usercmd_added = true
end


function M.init_auto_venv()
  if M._autocmd_venv_added then
    return
  end
  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('VenvLsp', { clear = true }),
    pattern = { "*.py" },
    callback = function()
      if M.disabled_auto_venv then
        return
      end
      venv.activate_buffer()
    end,
  })
  M._autocmd_venv_added = true
end

return M
