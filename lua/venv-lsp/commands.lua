local venv = require('venv-lsp.venv')
local cache = require('venv-lsp.cache')
local logger = require('venv-lsp.logger')
local config = require('venv-lsp.config')
local python = require('venv-lsp.python')

local M = {
  _autocmd_venv_init = false,
  _usercmd_init = false,
}

-- command functions

---Prompt user to add a venv mapping.
---@return nil
function M.add_venv()
  local current_dir = vim.fn.expand('%:p:h')
  vim.ui.input({ prompt = 'From root_dir: ', default = current_dir }, function(root_dir)
    if not root_dir or root_dir == '' then
      return
    end
    local root_dir_path = Path:new(root_dir)
    if not root_dir_path:exists() then
      logger.warn("Provided root_dir doesn't exist: " .. root_dir_path:get())
      return
    end
    vim.ui.input({ prompt = 'VENV path: ', default = vim.env.VIRTUAL_ENV }, function(venv_dir)
      if not venv_dir or venv_dir == '' then
        return
      end
      local venv_path = Path:new(venv_dir)
      local venv_python_path = python.get_python_executable_path(venv_path)
      if not venv_python_path:exists() then
        logger.warn("Provided virtualenv_path doesn't exist with this python executable: " .. venv_python_path:get())
        return
      end
      M.set_venv(root_dir, venv_dir)
    end)
  end)
end

---Prompt user to remove a venv mapping.
---@return nil
function M.remove_venv()
  vim.ui.select(vim.tbl_keys(cache.get_venv_cache()), {
    prompt = 'Remove: ',
    format_item = function(root_dir)
      return root_dir .. ' => ' .. cache[root_dir]
    end,
  }, function(root_dir)
    if not root_dir or root_dir == '' then
      return
    end
    M.set_venv(root_dir, nil)
  end)
end

function M.init_user_cmd()
  if M._usercmd_init then
    return
  end

  vim.api.nvim_create_user_command('VenvLspAddVenv', M.add_venv, { nargs = 0 })
  vim.api.nvim_create_user_command('VenvLspRemoveVenv', M.remove_venv, { nargs = 0 })
  vim.api.nvim_create_user_command('VenvLspAutoDisable', function()
    config.set_disable_auto_venv(true)
    logger.info('Auto VIRTUAL_ENV detection is disabled!')
  end, { nargs = 0 })
  vim.api.nvim_create_user_command('VenvLspAutoEnable', function()
    config.set_disable_auto_venv(false)
    logger.info('Auto VIRTUAL_ENV detection is enabled!')
  end, { nargs = 0 })
  vim.api.nvim_create_user_command('VenvLspCacheFile', function()
    vim.cmd.edit(config.get_cache_json_path:get())
  end, { nargs = 0 })

  M._usercmd_added = true
end

function M.init_auto_venv()
  if M._autocmd_venv_init then
    return
  end
  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('VenvLsp', { clear = true }),
    pattern = { '*.py' },
    callback = function()
      if not config.get().disabled_auto_venv then
        venv.activate_buffer()
      end
    end,
  })
  M._autocmd_venv_init = true
end

return M
