local util = require 'venv-lsp.util'
local poetry = require 'venv-lsp.venv_managers.poetry'

local M = {}

-- support for windows
M._is_win = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
M._venv_path_suffix = M._is_win and "\\Scripts;" or '/bin:'
M._python_path_suffix = M._is_win and "\\Scripts\\python.exe" or '/bin/python'

M._unknown_venv = '[UNKNOWN]'

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

function M.get_python_path(virtualenv_path)
  return virtualenv_path .. M._python_path_suffix
end

function M.activate_virtualenv(virtualenv_path)
  vim.env.VIRTUAL_ENV = virtualenv_path
  vim.env.PATH = virtualenv_path .. M._venv_path_suffix .. vim.env.PATH
end

function M.deactivate_virtualenv()
  if vim.env.VIRTUAL_ENV then
    vim.env.PATH = util.replace(vim.env.PATH, vim.env.VIRTUAL_ENV .. M._venv_path_suffix, "")
    vim.env.VIRTUAL_ENV = nil
  end
end

function M.activate_buffer()
  -- if buffer doesn't have VIRTUAL_ENV var
  if not vim.b.VIRTUAL_ENV then
    vim.b.VIRTUAL_ENV = vim.env.VIRTUAL_ENV or M._unknown_venv
    return
  end

  if vim.b.VIRTUAL_ENV == M._unknown_venv then
    M.deactivate_virtualenv()
    return
  end

  if vim.b.VIRTUAL_ENV ~= vim.env.VIRTUAL_ENV then
    M.deactivate_virtualenv()
    M.activate_virtualenv(vim.b.VIRTUAL_ENV)
  end
end

return M
