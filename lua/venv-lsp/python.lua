local common_os = require('venv-lsp.common.os')
local path = require('venv-lsp.common.path')

local python_executable_path_suffix = common_os.is_win and path.join('Scripts', 'python.exe')
    or path.join('bin', 'python')

local M = {}

---@param virtualenv_path string
---@return string
function M.get_python_path(virtualenv_path)
  return path.join(virtualenv_path, python_executable_path_suffix)
end

---@param python_path string
---@return string
function M.get_virtualenv_path(python_path)
  return path.remove_suffix(python_path, python_executable_path_suffix)
end

return M
