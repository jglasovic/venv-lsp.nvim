local fzf_vim = require('venv-lsp.selector.fzf_vim')
local fzf_lua = require('venv-lsp.selector.fzf_lua')
local telescope = require('venv-lsp.selector.telescope')
local nvim_ui = require('venv-lsp.selector.nvim_ui')

local all_selectors = {
  telescope,
  fzf_lua,
  fzf_vim,
  nvim_ui,
}

local filter_available = function(value)
  return value.is_available
end

local selectors = vim.tbl_filter(filter_available, all_selectors)
local selector = selectors[1]

local M = {}

function M.select_root_dir_path(default_dir_path, cb)
  selector.select_root_dir_path(default_dir_path, cb)
end

function M.select_venv_path(venv_list, cb)
  selector.select_venv_path(venv_list, cb)
end

return M
