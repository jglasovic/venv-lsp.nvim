local util = require 'venv-lsp.util'
local path_util = require('lspconfig.util').path

local M = {}

function M.get_virtualenv_path(dir_path)
  local cmd = 'cat ' .. path_util.join(dir_path, '.python-version')
  local venv_name = vim.fn.trim(vim.fn.system(cmd))
  if vim.v.shell_error ~= 0 or not venv_name then
    return nil
  end
  local pyenv_root = vim.fn.trim(vim.fn.system('pyenv root'))
  if vim.v.shell_error ~= 0 or not pyenv_root then
    return nil
  end
  local virtualenv_path = path_util.join(pyenv_root, 'versions', venv_name)
  if util.with_cache(util.path_exists, 'pyenv_venv')(virtualenv_path) then
    return virtualenv_path
  end
end

-- if pyenv is executable and path has .python-version - use pyenv
function M.should_use(path)
  local python_version_path = path_util.join(path, '.python-version')
  return util.with_cache(vim.fn.executable, 'exec')('pyenv') and
      util.with_cache(util.path_exists, 'pyenv_root')(python_version_path)
end

return M
