local shell = require('venv-lsp.common.shell')
local Path = require('venv-lsp.common.path')

local Poetry = {
  _cmd = 'poetry',
  has_exec = vim.fn.executable('poetry') and true or false,
  name = 'poetry',
}

---@return table
function Poetry.global_venv_paths()
  local cmd = Poetry._cmd .. ' config --local virtualenvs.path'
  local virtualenvs_path = shell.exec_str(cmd)
  if virtualenvs_path then
    local venv_dir = Path(virtualenvs_path)
    return venv_dir:list('directory')
  end
  return {}
end

---@param root_dir string
---@return boolean
function Poetry.is_venv(root_dir)
  if not root_dir or root_dir == vim.NIL then
    return false
  end
  local poetry_lock_path = Path(root_dir, 'poetry.lock')
  return poetry_lock_path:exists()
end

---@param root_dir string
---@return string|nil
function Poetry.get_venv(root_dir)
  local cmd = Poetry._cmd .. ' env info -p 2>/dev/null'
  local venv_path, code = shell.exec_str(cmd, root_dir)
  if code or not venv_path then
    return nil
  end
  return venv_path
end

---@type VenvManager
return Poetry
