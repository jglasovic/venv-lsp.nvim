local custom_os = require('venv-lsp.common.os')
local Path = require('venv-lsp.common.path')
local logger = require('venv-lsp.common.logger')
local venv_managers = require('venv-lsp.venv_managers')
local selectors = require('venv-lsp.selectors')
local config = require('venv-lsp.config')
local venv = require('venv-lsp.venv')
local python = require('venv-lsp.python')
local cache = require('venv-lsp.cache')

local selector = selectors.get()

---@class VenvLspCommands
---@field _autocmd_venv_init boolean
---@field _usercmd_init boolean
local M = {
  _autocmd_venv_init = false,
  _usercmd_init = false,
}

---Prompt user to add a venv mapping.
---@return nil
function M.add_venv()
  local current_dir = vim.fn.expand('%:p:h')
  selector.select_root_dir_path(current_dir, function(root_dir)
    if not root_dir then
      return
    end
    local root_dir_path = Path(root_dir)
    root_dir_path:normalize()
    root_dir = root_dir_path:get()
    if not root_dir_path:exists() then
      logger.error("Selected Root Directory doesn't exist: " .. root_dir)
      return
    end
    local venv_list = venv_managers.get_all_virtualenvs()
    selector.select_venv_path(venv_list, function(virtualenv_path)
      if not virtualenv_path then
        return
      end
      local venv_path = Path(virtualenv_path)
      venv_path:normalize()
      virtualenv_path = venv_path:get()
      local venv_python_path = Path(python.get_python_path(virtualenv_path))
      if not venv_python_path:exists() then
        logger.error("Python executable doesn't exist in selected virtual env path: " .. virtualenv_path)
      end
      cache.set_venv(root_dir, virtualenv_path)
      local msg = string.format(
        'Successfully added virtual environment for root_dir: [%s] -> venv: [%s]',
        root_dir,
        virtualenv_path
      )
      logger.info(msg)
    end)
  end)
end

---Prompt user to remove a venv mapping.
---@return nil
function M.remove_venv()
  local venv_cache = cache.get_venv_cache()
  vim.ui.select(vim.tbl_keys(venv_cache), {
    prompt = 'Remove: ',
    ---@param root_dir string
    format_item = function(root_dir)
      return root_dir .. ' => ' .. venv_cache[root_dir]
    end,
  }, function(root_dir)
    if not root_dir or root_dir == '' then
      return
    end
    local venv_path = venv_cache[root_dir]
    cache.set_venv(root_dir, nil)
    local msg =
      string.format('Successfully removed virtual environment for root_dir: [%s] -> venv: [%s]', root_dir, venv_path)
    logger.info(msg)
  end)
end

---@return nil
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
    vim.cmd.edit(config.get_cache_json_path():get())
  end, { nargs = 0 })

  M._usercmd_added = true
end

---@return nil
function M.init_auto_venv()
  if M._autocmd_venv_init then
    return
  end
  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('VenvLsp', { clear = true }),
    pattern = { '*.py' },
    callback = function()
      if not config.get().disable_auto_venv then
        venv.activate_buffer()
      end
    end,
  })
  M._autocmd_venv_init = true
end

return M
