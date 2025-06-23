local os = require('venv-lsp.common.os')
local utils = require('venv-lsp.common.utils')
local Path = require('venv-lsp.common.path')

local path_env_suffix = os.is_win and 'Scripts;' or 'bin:'
local executable_path_suffix = os.is_win and Path:new('Scripts', 'python.exe') or Path:new('bin', 'python')

local M = {}
---@param venv_path Path
---@return Path
M.get_python_executable_path = function(venv_path)
  return venv_path:join(executable_path_suffix)
end

---@param python_executable_path Path
---@return Path
M.get_venv_path = function(python_executable_path)
  return python_executable_path:remove_suffix(executable_path_suffix)
end

---@param venv_path Path
---@param path_env_str string
---@return string
M.append_venv_to_path_env_str = function(venv_path, path_env_str)
  local venv_path_str = venv_path:join(path_env_suffix):get()
  return venv_path_str .. path_env_str
end

---@param venv_path Path
---@param path_env_str string
---@return string
M.remove_venv_from_path_env_str = function(venv_path, path_env_str)
  local venv_path_str = venv_path:join(path_env_suffix):get()
  return utils.str_replace(path_env_str, venv_path_str, '')
end

return M
