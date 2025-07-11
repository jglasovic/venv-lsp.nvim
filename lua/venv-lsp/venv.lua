local common_os = require('venv-lsp.common.os')
local utils = require('venv-lsp.common.utils')
local path = require('venv-lsp.common.path')

local env_path_venv_suffix = common_os.is_win and 'Scripts;' or 'bin:'

local M = {}

---@param virtualenv_path string
function M.activate_virtualenv(virtualenv_path)
  local venv_path = path.join(virtualenv_path, env_path_venv_suffix)
  local new_path = venv_path .. common_os.get_env('PATH')
  common_os.set_env('VIRTUAL_ENV', virtualenv_path)
  common_os.set_env('PATH', new_path)
end

function M.deactivate_virtualenv()
  local virtualenv_path = common_os.get_env('VIRTUAL_ENV')
  if virtualenv_path then
    local venv_path = path.join(virtualenv_path, env_path_venv_suffix)
    local new_path = utils.str_replace(common_os.get_env('PATH') or '', venv_path, '')
    common_os.set_env('PATH', new_path)
    common_os.set_env('VIRTUAL_ENV', nil)
  end
end

function M.activate_buffer()
  if vim.b.VIRTUAL_ENV and vim.b.VIRTUAL_ENV ~= common_os.get_env('VIRTUAL_ENV') then
    M.deactivate_virtualenv()
    M.activate_virtualenv(vim.b.VIRTUAL_ENV)
  end
end

return M
