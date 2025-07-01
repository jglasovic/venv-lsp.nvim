local M = {
  is_available = true,
}

---@param values string[]
---@param prompt string
---@param custom_mappings KeyMapping[]|nil
---@return string[], table
local get_options = function(values, prompt, custom_mappings)
  prompt = prompt .. ':\n'
  if not custom_mappings or vim.tbl_isempty(custom_mappings) then
    return values, {
      prompt = prompt,
    }
  end
  local custom_prompt = { '\n(Aditional Options)' }
  local new_values = vim.tbl_deep_extend('force', {}, values)
  for _, mapping in ipairs(custom_mappings) do
    table.insert(new_values, mapping.value)
    table.insert(custom_prompt, mapping.value .. ' -> ' .. mapping.description)
  end
  local custom_str = table.concat(custom_prompt, '\n')
  if custom_str and custom_str ~= '' then
    prompt = prompt .. custom_str .. '\n'
  end
  return new_values, {
    prompt = prompt,
  }
end

---@param paths string[]
---@param cb fun(value:string|nil):nil
---@param custom_mappings KeyMapping[]|nil
function M.select_root_dir_path(paths, cb, custom_mappings)
  local modified_paths, opts = get_options(paths, 'Select Root Dir', custom_mappings)
  vim.ui.select(modified_paths, opts, function(root_path)
    if not root_path or root_path == '' then
      cb(nil)
    end
    cb(root_path)
  end)
end

---@param venvs string[]
---@param cb fun(value:string|nil):nil
---@param custom_mappings KeyMapping[]|nil
function M.select_venv_path(venvs, cb, custom_mappings)
  local modified_venvs, opts = get_options(venvs, 'Select Virtual Env', custom_mappings)
  vim.ui.select(modified_venvs, opts, function(virtualenv_path)
    if not virtualenv_path or virtualenv_path == '' then
      cb(nil)
    end
    cb(virtualenv_path)
  end)
end

return M
