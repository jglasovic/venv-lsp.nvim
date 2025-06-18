local utils = require('venv-lsp.utils')

local M = {}

function M.get_virtualenv_path(dir_path)
  local cmd = 'cat ' .. utils.path_join(dir_path, '.python-version')
  local venv_name = vim.fn.trim(vim.fn.system(cmd))
  if vim.v.shell_error ~= 0 or not venv_name then
    return nil
  end
  local pyenv_root = vim.fn.trim(vim.fn.system('pyenv root'))
  if vim.v.shell_error ~= 0 or not pyenv_root then
    return nil
  end
  local virtualenv_path = utils.path_join(pyenv_root, 'versions', venv_name)
  if utils.with_cache(utils.path_exists, 'pyenv_venv')(virtualenv_path) then
    return virtualenv_path
  end
end

-- if pyenv is executable and path has .python-version - use pyenv
function M.should_use(path)
  if not path or path == vim.NIL then
    return false
  end
  local python_version_path = utils.path_join(path, '.python-version')
  return utils.with_cache(vim.fn.executable, 'exec')('pyenv')
    and utils.with_cache(utils.path_exists, 'pyenv_root')(python_version_path)
end

return M
