local custom_os = require('venv-lsp.common.os')
local utils = require('venv-lsp.common.utils')
local Path = require('venv-lsp.common.path')

local env_path_venv_suffix = custom_os.is_win and 'Scripts;' or 'bin:'

local M = {}

---@param virtualenv_path string
function M.activate_virtualenv(virtualenv_path)
  local venv_path = Path(virtualenv_path, env_path_venv_suffix):get()
  local new_path = venv_path .. custom_os.get_env('PATH')
  custom_os.set_env('VIRTUAL_ENV', virtualenv_path)
  custom_os.set_env('PATH', new_path)
end

function M.deactivate_virtualenv()
  local virtualenv_path = custom_os.get_env('VIRTUAL_ENV')
  if virtualenv_path then
    local venv_path = Path(virtualenv_path, env_path_venv_suffix):get()
    local new_path = utils.str_replace(custom_os.get_env('PATH') or '', venv_path, '')
    custom_os.set_env('PATH', new_path)
    custom_os.set_env('VIRTUAL_ENV', nil)
  end
end

function M.activate_buffer()
  if vim.b.VIRTUAL_ENV and vim.b.VIRTUAL_ENV ~= custom_os.get_env('VIRTUAL_ENV') then
    M.deactivate_virtualenv()
    M.activate_virtualenv(vim.b.VIRTUAL_ENV)
  end
end

---@return string
function M.get_active_virtualenv()
  local virtualenv = custom_os.get_env('VIRTUAL_ENV')
  if virtualenv then
    local _, _, venv_name = string.find(virtualenv, '[/\\]([^/\\]+)$')
    return venv_name or ''
  end
  return ''
end

return M
