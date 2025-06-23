local python = require('venv-lsp.python')
local Path = require('venv-lsp.common.path')
local PythonManager = require('venv-lsp.venv_managers.python_manager')

Local = setmetatable({}, { __index = PythonManager })
Local.__index = Local

---@return PythonManager
function Local:new()
  local obj = setmetatable(PythonManager:new(), Local)
  self.__index = self
  obj.has_exec = true
  obj.name = 'local'
  return obj
end

---@param root_dir string|nil
---@return table
function Local:_get_venvs(root_dir)
  local venvs = {}
  if not root_dir or root_dir == vim.NIL then
    return {}
  end
  --
  -- project
  -- |__ venv or .venv    <--- check if name of the folder is 'venv' or '.venv'
  --     |__ Scripts/bin
  --         |__ python  <--- interpreterPath
  --
  local venv_dir = Path:new(root_dir, 'venv')
  local python_path_venv = python.get_python_executable_path(venv_dir)
  local dot_venv_dir = Path:new(root_dir, '.venv')
  local python_path_dot_venv = python.get_python_executable_path(dot_venv_dir)
  if venv_dir:exists() and python_path_venv:exists() then
    table.insert(venvs, venv_dir:get())
  end
  if dot_venv_dir:exists() and python_path_dot_venv:exists() then
    table.insert(venvs, dot_venv_dir:get())
  end
  return venvs
end

---@param root_dir string
---@return boolean
function Local:is_venv(root_dir)
  if not root_dir or root_dir == vim.NIL then
    return false
  end
  local venvs = self:_get_venvs(root_dir)
  if vim.tbl_isempty(venvs) then
    return false
  end
  return true
end

---@param root_dir string
---@return string|nil
function Local:get_venv(root_dir)
  if not root_dir or root_dir == vim.NIL then
    return nil
  end
  local venvs = self:_get_venvs(root_dir)
  if vim.tbl_isempty(venvs) then
    return nil
  end
  -- return first one
  return venvs[1]
end

--- returning all local venvs if exists
---@return table
function Local:global_venv_paths()
  return self:_get_venvs(vim.fn.cwd())
end

return Local
