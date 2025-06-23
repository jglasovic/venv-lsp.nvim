local Path = require('venv-lsp.common.path')
local python = require('venv-lsp.python')
local cache = require('venv-lsp.cache')

--- venv_managers
local LocalVenv = require('venv-lsp.venv_managers.local')
local Poetry = require('venv-lsp.venv_managers.poetry')
local Pyenv = require('venv-lsp.venv_managers.pyenv')

local local_venv = LocalVenv:new()
local poetry = Poetry:new()
local pyenv = Pyenv:new()

local support_auto_venv_detection = { local_venv, poetry, pyenv }

local M = {}

---@param root_dir string
---@return string?
function M._find_virtualenv_path(root_dir)
  for _, venv_manager in ipairs(support_auto_venv_detection) do
    if venv_manager.has_exec and venv_manager:is_venv(root_dir) then
      local virtualenv_path = venv_manager:get_venv(root_dir)
      if virtualenv_path then
        return virtualenv_path
      end
    end
  end
  return nil
end

---@param virtualenv_path string
---@return string
function M._get_python_path(virtualenv_path)
  local venv_path = Path:new(virtualenv_path)
  return python.get_python_executable_path(venv_path):get()
end

---@param root_dir string
---@return string?
function M.get_virtualenv_path(root_dir)
  return cache.with_memcache(M._find_virtualenv_path, 'venv')(root_dir)
end

---@param virtualenv_path string
---@return string?
function M.get_python_path(virtualenv_path)
  return cache.with_memcache(M._get_python_path, 'venv_python')(virtualenv_path)
end

---@param virtualenv_path string
function M.activate_virtualenv(virtualenv_path)
  vim.env.VIRTUAL_ENV = virtualenv_path
  local venv_path = Path:new(virtualenv_path)
  vim.env.PATH = python.append_venv_to_path_env_str(venv_path, vim.env.PATH)
end

function M.deactivate_virtualenv()
  if vim.env.VIRTUAL_ENV then
    local venv_path = Path:new(vim.env.VIRTUAL_ENV)
    vim.env.PATH = python.remove_venv_from_path_env_str(venv_path, vim.env.PATH)
    vim.env.VIRTUAL_ENV = nil
  end
end

function M.activate_buffer()
  if vim.b.VIRTUAL_ENV and vim.b.VIRTUAL_ENV ~= vim.env.VIRTUAL_ENV then
    M.deactivate_virtualenv()
    M.activate_virtualenv(vim.b.VIRTUAL_ENV)
  end
end

return M
