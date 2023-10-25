local util = require 'venv-lsp.util'
local poetry = require 'venv-lsp.venv_managers.poetry'

local M = {}

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
  local venv_path = util.with_cache(M._find_virtualenv_path, 'venv')(path)
  M.LRU = venv_path
  return venv_path
end

function M.set_virtualenv_tbl(env_tbl, virtualenv_path)
  if not virtualenv_path then
    return env_tbl
  end

  if not env_tbl then
    env_tbl = {}
  end
  -- always override VIRTUAL_ENV var even if it is explicitly added
  env_tbl.VIRTUAL_ENV = virtualenv_path

  if not env_tbl.PATH then
    -- TODO: could also cache
    env_tbl.PATH = vim.env.PATH
  end
  -- append to PATH
  -- TODO: fix for different systems (working on macos)
  env_tbl.PATH = virtualenv_path .. '/bin:' .. env_tbl.PATH
  return env_tbl
end

-- Function to activate a virtual environment
function M.activate_virtualenv(venv_path)
  vim.env.VIRTUAL_ENV = venv_path
  vim.env.PATH = venv_path .. '/bin:' .. vim.env.PATH
end

-- Function to deactivate a virtual environment
function M.deactivate_virtualenv()
  if vim.env.VIRTUAL_ENV then
    local venv_path = vim.env.VIRTUAL_ENV
    vim.env.PATH = string.gsub(vim.env.PATH, venv_path .. '/bin:', '')
    vim.env.VIRTUAL_ENV = nil
  end
end

return M
