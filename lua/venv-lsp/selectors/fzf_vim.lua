local fzf_run = vim.fn['fzf#run']
local fzf_wrap = vim.fn['fzf#wrap']

local M = {
  is_available = not not (fzf_run and fzf_wrap),
}

---@param prompt string
---@param custom_mappings KeyMapping[]|nil
local get_options = function(prompt, custom_mappings)
  local options = {
    '--prompt=' .. prompt .. '> ',
    '--no-multi',
    '--keep-right',
    '--inline-info',
    '--color=header:italic,label:blue',
  }
  if not custom_mappings or vim.tbl_isempty(custom_mappings) then
    return options
  end
  local headers = {}
  for _, mapping in ipairs(custom_mappings) do
    table.insert(options, '--bind=' .. mapping.key .. ':become(echo ' .. mapping.value .. ')')
    table.insert(headers, ' ' .. string.upper(mapping.key) .. ' (' .. mapping.description .. ') ')
  end
  if not vim.tbl_isempty(headers) then
    table.insert(options, '--header=::' .. table.concat(headers, ' ╱ ') .. '\n')
  end
  return options
end

---@param paths string[]
---@param cb fun(value:string):nil
---@param custom_mappings KeyMapping[]|nil
function M.select_root_dir_path(paths, cb, custom_mappings)
  local options = get_options('Select Root Dir', custom_mappings)
  fzf_run(fzf_wrap({
    source = paths,
    sink = cb,
    options = options,
  }))
end

---@param venvs string[]
---@param cb fun(value:string):nil
---@param custom_mappings KeyMapping[]|nil
function M.select_venv_path(venvs, cb, custom_mappings)
  local options = get_options('Select Virtual Env', custom_mappings)
  fzf_run(fzf_wrap({
    source = venvs,
    sink = cb,
    options = options,
  }))
end

return M
