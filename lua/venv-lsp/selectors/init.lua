local fzf_vim = require('venv-lsp.selectors.fzf_vim')
local fzf_lua = require('venv-lsp.selectors.fzf_lua')
local telescope = require('venv-lsp.selectors.telescope')
local nvim_ui = require('venv-lsp.selectors.nvim_ui')

---@class Selector
---@field is_available boolean
---@field select_root_dir_path fun(paths: string[], cb: (fun(value:string|nil):nil),c:table|nil):nil
---@field select_venv_path fun(virtualenvs: string[], cb: (fun(value:string|nil):nil), c:table|nil):nil

---@class KeyMapping
---@field key string
---@field value string
---@field description string

---@type Selector[]
local all_selectors = {
  -- order matters, searching for available in this order ->
  telescope,
  fzf_lua,
  fzf_vim,
  nvim_ui, -- default one
}

---@param value Selector
---@return boolean
local filter_available = function(value)
  return value.is_available
end

local selectors = vim.tbl_filter(filter_available, all_selectors)
-- nvim_ui is a default one if no other exists
local available_selector = selectors[1]

local M = {}

---@coroutine
---@param paths string[]
---@param custom_mappings KeyMapping[]|nil
---@return string|nil
function M.select_root_dir_path(paths, custom_mappings)
  local co = coroutine.running()
  available_selector.select_root_dir_path(paths, function(value)
    vim.schedule(function()
      coroutine.resume(co, value)
    end)
  end, custom_mappings)
  return coroutine.yield()
end

---@coroutine
---@param virtualenv_paths string[]
---@param custom_mappings KeyMapping[]|nil
---@return string|nil
function M.select_venv_path(virtualenv_paths, custom_mappings)
  local co = coroutine.running()
  available_selector.select_venv_path(virtualenv_paths, function(value)
    vim.schedule(function()
      coroutine.resume(co, value)
    end)
  end, custom_mappings)
  return coroutine.yield()
end

---@coroutine
---@param root_dir string
---@return string|nil
function M.add_root_dir_path(root_dir)
  local co = coroutine.running()
  vim.ui.input({ prompt = 'Root Directory: ', default = root_dir }, function(value)
    if not value or value == '' then
      vim.schedule(function()
        coroutine.resume(co, nil)
      end)
      return
    end
    vim.schedule(function()
      coroutine.resume(co, value)
    end)
  end)
  return coroutine.yield()
end

---@coroutine
---@param venv_path string
---@return string|nil
function M.add_venv_path(venv_path)
  local co = coroutine.running()
  vim.ui.input({ prompt = 'Virtual Env Path: ', default = venv_path }, function(value)
    if not value or value == '' then
      vim.schedule(function()
        coroutine.resume(co, nil)
      end)
      return
    end
    vim.schedule(function()
      coroutine.resume(co, value)
    end)
  end)
  return coroutine.yield()
end

return M
