local cache = require('venv-lsp.cache')

local local_venv = require('venv-lsp.venv_managers.local_venv')
local poetry = require('venv-lsp.venv_managers.poetry')
local pyenv = require('venv-lsp.venv_managers.pyenv')

---@class VenvManager
---@field name string
---@field has_exec boolean
---@field is_venv nil|fun(root_dir: string): boolean
---@field get_venv fun(root_dir: string): string|nil
---@field global_venv_paths fun(root_dir: string): table

---@type VenvManager[]
local venv_managers = { local_venv, poetry, pyenv }

---@param value VenvManager
---@return boolean
local filter_executable = function(value)
  return value.has_exec
end

---@param value VenvManager
---@return boolean
local filter_auto_venv_support = function(value)
  return not not value.is_venv
end

local supported_venv_managers = vim.tbl_filter(filter_executable, venv_managers)
local auto_detect_venv_supported_managers =
  vim.tbl_filter(filter_auto_venv_support, supported_venv_managers)

---@param root_dir string
---@param reset_cache boolean|nil
---@return string[]
local get_all_virtualenvs = function(root_dir, reset_cache)
  local result = {}
  for _, venv_manager in ipairs(supported_venv_managers) do
    if reset_cache then
      cache.reset_memcache(venv_manager.name)
    end

    local virtualenvs
    if venv_manager.name == 'local_venv' then
      -- local env depends on root_dir
      virtualenvs = cache.with_memcache(venv_manager.global_venv_paths, venv_manager.name)(root_dir)
    else
      -- it will always be cached unless explicitly requested to reset
      virtualenvs = cache.with_memcache(venv_manager.global_venv_paths, venv_manager.name)('global')
    end
    result = vim.list_extend(result, virtualenvs)
  end
  return result
end

local M = {}

---@param root_dir string
---@return string|nil
function M.auto_detect_virtualenv(root_dir)
  for _, venv_manager in ipairs(auto_detect_venv_supported_managers) do
    if venv_manager.is_venv(root_dir) then
      local virtualenv_path = venv_manager.get_venv(root_dir)
      if virtualenv_path then
        return virtualenv_path
      end
    end
  end
  return nil
end

---@param root_dir string
---@param reset_cache boolean|nil
---@return string[]
function M.get_all_virtualenvs(root_dir, reset_cache)
  if reset_cache then
    cache.reset_memcache('global_venvs')
  end
  return cache.with_memcache(function(key)
    return get_all_virtualenvs(key, reset_cache)
  end, 'global_venvs')(root_dir)
end

return M
