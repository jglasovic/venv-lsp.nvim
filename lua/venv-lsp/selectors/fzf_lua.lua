local is_available = pcall(require, 'fzf-lua')

local M = { is_available = is_available }

---@param prompt string
---@param custom_mappings KeyMapping[]|nil
local get_options = function(prompt, custom_mappings, cb)
  local options = {
    prompt = prompt .. '> ',
    multi = false,
    fzf_opts = {
      ['--keep-right'] = true,
      ['--inline-info'] = true,
      ['--color'] = 'header:italic,label:blue',
    },
  }
  local actions = {
    ['default'] = function(selected)
      cb(selected[1])
    end,
  }
  if not custom_mappings or vim.tbl_isempty(custom_mappings) then
    options.actions = actions
    return options
  end
  local headers = {}
  for _, mapping in ipairs(custom_mappings) do
    actions[mapping.key] = function()
      cb(mapping.value)
    end
    table.insert(headers, ' ' .. string.upper(mapping.key) .. ' (' .. mapping.description .. ') ')
  end
  if not vim.tbl_isempty(headers) then
    options.header = '::' .. table.concat(headers, ' ╱ ') .. '\n'
  end
  options.actions = actions
  return options
end

if is_available then
  local fzf_lua = require('fzf-lua')
  function M.select_root_dir_path(paths, cb, custom_mappings)
    local opts = get_options('Select Root Dir', custom_mappings, cb)
    fzf_lua.fzf_exec(paths, opts)
  end

  function M.select_venv_path(venvs, cb, custom_mappings)
    local opts = get_options('Select Virtual Env', custom_mappings, cb)
    fzf_lua.fzf_exec(venvs, opts)
  end
end

return M
