local util = require 'venv-lsp.util'

local M = {}

function M.get_virtualenv_path(dir_path)
  local cmd = 'poetry -C ' .. dir_path .. ' env info -p'
  local virtualenv_path = vim.fn.trim(vim.fn.system(cmd))
  return virtualenv_path
end

-- if poetry is executable and path has pyproject.toml - use poetry
function M.should_use(path)
  local pyproject_path = path ..'/pyproject.toml'
  return util.with_cache(vim.fn.executable, 'exec')('poetry') and util.with_cache(util.path_exists, 'poetry_root')(pyproject_path)
end

return M
