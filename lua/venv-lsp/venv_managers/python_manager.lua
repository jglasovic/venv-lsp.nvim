---@class PythonManager
---@field name string
---@field has_exec boolean
---@field _cmd string
PythonManager = { has_exec = false, name = '' }
PythonManager.__index = PythonManager

function PythonManager:new()
  self = setmetatable({}, PythonManager)
  return self
end

---@return table
function PythonManager:global_venvs_paths()
  error('global_venvs_paths() must be implemented by subclass')
end

---@param root_dir string
---@return boolean
function PythonManager:is_venv(root_dir)
  _ = root_dir
  error('is_venv() must be implemented by subclass')
end

---@param root_dir string
---@return string?
function PythonManager:get_venv(root_dir)
  _ = root_dir
  error('get_venv() must be implemented by subclass')
end

return PythonManager
