local fzf_vim = require('venv-lsp.selectors.fzf_vim')
local fzf_lua = require('venv-lsp.selectors.fzf_lua')
local telescope = require('venv-lsp.selectors.telescope')
local nvim_ui = require('venv-lsp.selectors.nvim_ui')

local all_selectors = {
  -- order matters, searching for available in this order ->
  telescope,
  fzf_lua,
  fzf_vim,
  nvim_ui, -- default one
}

local filter_available = function(value)
  return value.is_available
end

local selectors = vim.tbl_filter(filter_available, all_selectors)
-- nvim_ui is a default one if no other exists
local available_selector = selectors[1]

return {
  get = function()
    return available_selector
  end,
}
