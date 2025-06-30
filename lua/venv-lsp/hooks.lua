local common_os = require('venv-lsp.common.os')
local const = require('venv-lsp.common.constants')
local venv = require('venv-lsp.venv')
local python = require('venv-lsp.python')
local venv_managers = require('venv-lsp.venv_managers')
local cache = require('venv-lsp.cache')
local config = require('venv-lsp.config').get()

---@param root_dir string
---@return string|nil
local get_virtualenv = function(root_dir)
  -- check if the cache exists
  local virtualenv_path = cache.get_venv(root_dir)
  if virtualenv_path then
    return virtualenv_path
  end
  virtualenv_path = venv_managers.auto_detect_virtualenv(root_dir)
  if virtualenv_path then
    cache.set_venv(root_dir, virtualenv_path)
  end
  return virtualenv_path
end

local M = {}

---@param update_config fun(config: table, python_path: string): nil
---@return fun(config: table, root_dir: string): nil
function M.get_on_new_config(update_config)
  return function(new_config, root_dir)
    if config.disable_auto_venv then
      return
    end
    -- save current active venv
    local previous_venv = common_os.get_env('VIRTUAL_ENV')
    -- deactivate previous venv before searching for the new one
    venv.deactivate_virtualenv()
    local virtualenv_path = get_virtualenv(root_dir) or previous_venv

    if virtualenv_path then
      local python_path = python.get_python_path(virtualenv_path)
      update_config(new_config, python_path)
      venv.activate_virtualenv(virtualenv_path)
      -- store venv_path value for on attach to save it on buffer
      new_config[const.lsp.custom_venv] = virtualenv_path
    end
  end
end

---@param client vim.lsp.Client
---@param bufnr integer
---@return nil
function M.on_attach(client, bufnr)
  local venv_path = vim.tbl_get(client, 'config', const.lsp.custom_venv)
  if venv_path then
    vim.api.nvim_buf_set_var(bufnr, 'VIRTUAL_ENV', venv_path)
    venv.activate_buffer()
  end
end

return M
