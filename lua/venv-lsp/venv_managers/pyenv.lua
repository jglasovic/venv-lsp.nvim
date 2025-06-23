local os = require('venv-lsp.common.os')
local shell = require('venv-lsp.common.shell')
local python = require('venv-lsp.python')
local Path = require('venv-lsp.common.path')
local PythonManager = require('venv-lsp.venv_managers.python_manager')

Pyenv = setmetatable({}, { __index = PythonManager })
Pyenv.__index = Pyenv

---@return PythonManager
function Pyenv:new()
  local obj = setmetatable(PythonManager:new(), Pyenv)
  self.__index = self
  obj._cmd = 'pyenv'
  obj.has_exec = vim.fn.executable(obj._cmd) and true or false
  obj.name = 'pyenv'
  return obj
end

---@return table
function Pyenv:global_venv_paths()
  local virtualenvs = {}
  local pyenv_root = os.get_env('PYENV_ROOT') or os.get_env('PYENV')
  if not pyenv_root then
    return virtualenvs
  end
  local cmd = self._cmd .. ' versions --skip-aliases --bare'
  local pyenv_python_versions = shell.exec(cmd)
  if pyenv_python_versions then
    -- filter envs
    for _, path in ipairs(pyenv_python_versions) do
      if string.find(path, 'envs') then
        table.insert(virtualenvs, Path:new(pyenv_root, path):get())
      end
    end
  end
  return virtualenvs
end

---@param root_dir string
---@return boolean
function Pyenv:is_venv(root_dir)
  if not root_dir or root_dir == vim.NIL then
    return false
  end
  local python_version_path = Path:new(root_dir, '.python-version')
  return python_version_path:exists()
end

---@param root_dir string
---@return string|nil
function Pyenv:get_venv(root_dir)
  local cmd = self._cmd .. ' which python'
  local venv_python_executable_path_str, code = shell.exec_str(cmd, root_dir)
  if code or not venv_python_executable_path_str then
    return nil
  end
  local venv_python_executable_path = Path:new(venv_python_executable_path_str)
  return python.get_venv_path(venv_python_executable_path):get()
end

return Pyenv
