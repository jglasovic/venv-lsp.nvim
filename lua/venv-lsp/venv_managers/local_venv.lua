local path = require('venv-lsp.common.path')
local python = require('venv-lsp.python')

local M = {
  has_exec = true,
  name = 'local_venv',
  _cmd = '',
}

---@param root_dir string|nil
---@return table
function M._get_venvs(root_dir)
  local venvs = {}
  if not root_dir or root_dir == vim.NIL then
    return {}
  end
  --
  -- project
  -- |__ venv or .venv or <named_venv_dir>    <--- check if there is a dir with /Scripts/python.exe or /bin/python
  --     |__ Scripts/bin
  --         |__ python  <--- interpreterPath
  --
  local project_dirs = path.list(root_dir, 'directory')
  for _, dir in ipairs(project_dirs) do
    local python_path_venv = python.get_python_path(dir)
    if path.exists(python_path_venv) then
      table.insert(venvs, dir)
    end
  end
  return venvs
end

---@param root_dir string
---@return boolean
function M.is_venv(root_dir)
  if not root_dir or root_dir == vim.NIL then
    return false
  end
  local venvs = M._get_venvs(root_dir)
  if vim.tbl_isempty(venvs) then
    return false
  end
  return true
end

---@param root_dir string
---@return string|nil
function M.get_venv(root_dir)
  if not root_dir or root_dir == vim.NIL then
    return nil
  end
  local venvs = M._get_venvs(root_dir)
  if vim.tbl_isempty(venvs) then
    return nil
  end
  -- return first one
  return venvs[1]
end

--- returning all local venvs if exists
---@return table
function M.global_venv_paths(root_dir)
  return M._get_venvs(root_dir)
end

return M
