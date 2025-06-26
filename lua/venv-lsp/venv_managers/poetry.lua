local shell = require('venv-lsp.common.shell')
local path = require('venv-lsp.common.path')

local M = {
  _cmd = 'poetry',
  has_exec = vim.fn.executable('poetry') and true or false,
  name = 'poetry',
}

---@return table
function M.global_venv_paths()
  local cmd = M._cmd .. ' config --local virtualenvs.path'
  local venv_path = shell.exec_str(cmd)
  if venv_path then
    return path.list(venv_path, 'directory')
  end
  return {}
end

---@param root_dir string
---@return boolean
function M.is_venv(root_dir)
  if not root_dir or root_dir == vim.NIL then
    return false
  end
  local poetry_lock_path = path.join(root_dir, 'poetry.lock')
  return path.exists(poetry_lock_path)
end

---@param root_dir string
---@return string|nil
function M.get_venv(root_dir)
  local cmd = M._cmd .. ' env info -p 2>/dev/null'
  local venv_path, code = shell.exec_str(cmd, root_dir)
  if code or not venv_path then
    return nil
  end
  return venv_path
end

---@type VenvManager
return M
