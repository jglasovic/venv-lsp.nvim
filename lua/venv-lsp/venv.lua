local util = require 'venv-lsp.util'
local poetry = require 'venv-lsp.venv_managers.poetry'

local M = {}

function M.get_virtualenv_path(path)
  if poetry.should_use(path) then
    local virtualenv_path = util.with_cache(poetry.get_virtualenv_path, 'virtualenv_path', true)(path)
    if virtualenv_path then
      return virtualenv_path
    end
  end
  -- TODO: add other checks to support other virtualenv managers
  return nil
end

function M.set_virtualenv_var(env_tbl, virtualenv_path)
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
    env_tbl.PATH = os.getenv('PATH')
  end
  -- append to PATH
  -- TODO: fix for different systems (working on macos)
  env_tbl.PATH = virtualenv_path .. '/bin:' .. env_tbl.PATH
  return env_tbl
end

return M
