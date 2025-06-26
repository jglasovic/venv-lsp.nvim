local path = require('venv-lsp.common.path')
local python = require('venv-lsp.python')

local uv = (vim.uv or vim.loop)

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
  -- |__ venv or .venv    <--- check if name of the folder is 'venv' or '.venv'
  --     |__ Scripts/bin
  --         |__ python  <--- interpreterPath
  --
  local venv_dir = path.join(root_dir, 'venv')
  local python_path_venv = python.get_python_path(venv_dir)
  local dot_venv_dir = path.join(root_dir, '.venv')
  local python_path_dot_venv = python.get_python_path(dot_venv_dir)

  if path.exists(python_path_venv) then
    table.insert(venvs, venv_dir)
  end
  if path.exists(python_path_dot_venv) then
    table.insert(venvs, dot_venv_dir)
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
function M.global_venv_paths()
  return M._get_venvs(uv.cwd())
end

return M
