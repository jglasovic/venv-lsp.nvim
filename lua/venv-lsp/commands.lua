local common_os = require('venv-lsp.common.os')
local path = require('venv-lsp.common.path')
local logger = require('venv-lsp.common.logger')
local venv_managers = require('venv-lsp.venv_managers')
local config = require('venv-lsp.config')
local venv = require('venv-lsp.venv')
local python = require('venv-lsp.python')
local cache = require('venv-lsp.cache')
local selector = require('venv-lsp.selectors').get()

local uv = vim.uv or vim.loop

local home_dir = uv.os_homedir()

---@class VenvLspCommands
---@field _autocmd_venv_init boolean
---@field _usercmd_init boolean
local M = {
  _autocmd_venv_init = false,
  _usercmd_init = false,
}

---Stop at root or home dir or parent git dir
---@param dir string
---@return boolean
local should_stop = function(dir)
  local is_root = common_os.is_win and dir:match('^%a:[/\\]?$') or dir == '/'
  return is_root or home_dir == dir or path.exists(path.join(dir, '.git'))
end

---Prompt user to add a venv mapping.
---@return nil
function M.add_venv()
  local paths = path.list_parents(vim.api.nvim_buf_get_name(0), should_stop, true)
  selector.select_root_dir_path(paths, function(root_dir)
    if not root_dir then
      return
    end
    root_dir = path.normalize(root_dir)
    if not path.exists(root_dir) then
      logger.error("Selected Root Directory doesn't exist: " .. root_dir)
      return
    end

    -- cache in memory
    local venv_list = cache.with_memcache(function(_)
      return venv_managers.get_all_virtualenvs()
    end, 'global_venvs')('all')

    selector.select_venv_path(venv_list, function(virtualenv_path)
      if not virtualenv_path then
        return
      end
      virtualenv_path = path.normalize(virtualenv_path)
      local venv_python_path = python.get_python_path(virtualenv_path)
      if not path.exists(venv_python_path) then
        logger.error(
          "Python executable doesn't exist in selected virtual env path: " .. virtualenv_path
        )
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
    local msg = string.format(
      'Successfully removed virtual environment for root_dir: [%s] -> venv: [%s]',
      root_dir,
      venv_path
    )
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
  vim.api.nvim_create_user_command('VenvLspCacheDisable', function()
    config.update({ disable_cache = true })
    logger.info('VIRTUAL_ENV cache is disabled!')
  end, { nargs = 0 })
  vim.api.nvim_create_user_command('VenvLspCacheEnable', function()
    config.update({ disable_cache = true })
    logger.info('VIRTUAL_ENV Cache is enabled!')
  end, { nargs = 0 })
  vim.api.nvim_create_user_command('VenvLspAutoDisable', function()
    config.update({ disable_auto_venv = true })
    logger.info('Auto VIRTUAL_ENV detection is disabled!')
  end, { nargs = 0 })
  vim.api.nvim_create_user_command('VenvLspAutoEnable', function()
    config.update({ disable_auto_venv = true })
    logger.info('Auto VIRTUAL_ENV detection is enabled!')
  end, { nargs = 0 })
  vim.api.nvim_create_user_command('VenvLspCacheFile', function()
    vim.cmd.edit(config.get().cache_json_path)
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
