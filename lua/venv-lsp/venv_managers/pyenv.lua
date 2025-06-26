local custom_os = require('venv-lsp.common.os')
local shell = require('venv-lsp.common.shell')
local path = require('venv-lsp.common.path')
local python = require('venv-lsp.python')

local Pyenv = {
  _cmd = 'pyenv',
  has_exec = vim.fn.executable('pyenv') and true or false,
  name = 'pyenv',
}
---@return table
function Pyenv.global_venv_paths()
  local virtualenvs = {}
  local pyenv_root = custom_os.get_env('PYENV_ROOT') or custom_os.get_env('PYENV')
  if not pyenv_root then
    return virtualenvs
  end
  local cmd = Pyenv._cmd .. ' versions --skip-aliases --bare'
  local pyenv_python_versions = shell.exec(cmd)
  if pyenv_python_versions then
    -- filter envs
    for _, envs_path in ipairs(pyenv_python_versions) do
      if string.find(envs_path, 'envs') then
        table.insert(virtualenvs, path.join(pyenv_root, envs_path))
      end
    end
  end
  return virtualenvs
end

---@param root_dir string
---@return boolean
function Pyenv.is_venv(root_dir)
  if not root_dir or root_dir == vim.NIL then
    return false
  end
  local python_version_path = path.join(root_dir, '.python-version')
  return path.exists(python_version_path)
end

---@param root_dir string
---@return string|nil
function Pyenv.get_venv(root_dir)
  local cmd = Pyenv._cmd .. ' which python'
  local python_path, code = shell.exec_str(cmd, root_dir)
  if code or not python_path then
    return nil
  end
  return python.get_virtualenv_path(python_path)
end

---@type VenvManager
return Pyenv
