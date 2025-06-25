local custom_os = require('venv-lsp.common.os')
local Path = require('venv-lsp.common.path')

local python_executable_path_suffix = custom_os.is_win and Path('Scripts', 'python.exe'):get()
  or Path('bin', 'python'):get()

local M = {}

---@param virtualenv_path string
---@return string
function M.get_python_path(virtualenv_path)
  return Path(virtualenv_path, python_executable_path_suffix):get()
end

---@param python_path string
---@return string
function M.get_virtualenv_path(python_path)
  return Path(python_path):remove_suffix(python_executable_path_suffix):get()
end

return M
