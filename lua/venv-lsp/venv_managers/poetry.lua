local shell = require('venv-lsp.common.shell')
local Path = require('venv-lsp.common.path')
local PythonManager = require('venv-lsp.venv_managers.python_manager')

Poetry = setmetatable({}, { __index = PythonManager })
Poetry.__index = Poetry

---@return PythonManager
function Poetry:new()
  local obj = setmetatable(PythonManager:new(), Poetry)
  self.__index = self
  obj._cmd = 'poetry'
  obj.has_exec = vim.fn.executable(obj._cmd) and true or false
  obj.name = 'poetry'
  return obj
end

---@return table
function Poetry:global_venv_paths()
  local cmd = self._cmd .. ' config --local virtualenvs.path'
  local virtualenvs_path = shell.exec_str(cmd)
  if virtualenvs_path then
    local venv_dir = Path:new(virtualenvs_path)
    return venv_dir:list()
  end
  return {}
end

---@param root_dir string
---@return boolean
function Poetry:is_venv(root_dir)
  if not root_dir or root_dir == vim.NIL then
    return false
  end
  local poetry_lock_path = Path:new(root_dir, 'poetry.lock')
  return poetry_lock_path:exists()
end

---@param root_dir string
---@return string|nil
function Poetry:get_venv(root_dir)
  local cmd = self._cmd .. ' env info -p 2>/dev/null'
  local venv_path, code = shell.exec_str(cmd, root_dir)
  if code or not venv_path then
    return nil
  end
  return venv_path
end

return Poetry
