local util = require 'venv-lsp.util'
local poetry = require 'venv-lsp.venv_managers.poetry'

local M = {}

-- support for windows
M._is_win = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
M._venv_path_suffix = M._is_win and "\\Scripts;" or '/bin:'
M._python_path_suffix = M._is_win and "\\Scripts\\python.exe" or '/bin/python'

function M._find_virtualenv_path(path)
  -- poetry support
  if poetry.should_use(path) then
    local virtualenv_path = poetry.get_virtualenv_path(path)
    if virtualenv_path then
      return virtualenv_path
    end
  end
  -- TODO: add other checks to support other virtualenv managers
  -- pipenv
  -- pyenv
  return nil
end

function M.get_virtualenv_path(path)
  return util.with_cache(M._find_virtualenv_path, 'venv')(path)
end

function M.get_python_path(venv_path)
  return venv_path .. M._python_path_suffix
end

function M.activate_virtualenv(venv_path)
  vim.env.VIRTUAL_ENV = venv_path
  vim.env.PATH = venv_path .. M._venv_path_suffix .. vim.env.PATH
end

function M.deactivate_virtualenv()
  if vim.env.VIRTUAL_ENV then
    vim.env.PATH = util.replace(vim.env.PATH, vim.env.VIRTUAL_ENV .. M._venv_path_suffix, "")
    vim.env.VIRTUAL_ENV = nil
  end
end

return M
