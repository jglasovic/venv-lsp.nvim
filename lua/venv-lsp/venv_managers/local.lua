local Path = require('venv-lsp.common.path')
local python = require('venv-lsp.python')

local uv = (vim.uv or vim.loop)

local Local = {
  has_exec = true,
  name = 'local',
  _cmd = '',
}

---@param root_dir string|nil
---@return table
function Local._get_venvs(root_dir)
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
  local venv_dir = Path(root_dir, 'venv')
  local python_path_venv = Path(python.get_python_path(venv_dir:get()))
  local dot_venv_dir = Path(root_dir, '.venv')
  local python_path_dot_venv = Path(python.get_python_path(dot_venv_dir:get()))

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
function Local.is_venv(root_dir)
  if not root_dir or root_dir == vim.NIL then
    return false
  end
  local venvs = Local._get_venvs(root_dir)
  if vim.tbl_isempty(venvs) then
    return false
  end
  return true
end

---@param root_dir string
---@return string|nil
function Local.get_venv(root_dir)
  if not root_dir or root_dir == vim.NIL then
    return nil
  end
  local venvs = Local._get_venvs(root_dir)
  if vim.tbl_isempty(venvs) then
    return nil
  end
  -- return first one
  return venvs[1]
end

--- returning all local venvs if exists
---@return table
function Local.global_venv_paths()
  return Local._get_venvs(uv.cwd())
end

---@type VenvManager
return Local
