local is_available = pcall(require, 'telescope')
local M = {
  is_available = is_available,
}

local remap_ctrl = function(key)
  -- key can be 'ctrl-{char}' - convert that to <C-{char}>'
  return key:gsub('[Cc]trl%-(%w)', '<C-%1>')
end

local get_prompt = function(prompt, custom_mappings)
  if custom_mappings and not vim.tbl_isempty(custom_mappings) then
    prompt = prompt
      .. ' :: '
      .. table.concat(
        vim.tbl_map(function(i)
          return string.upper(i.key) .. ' (' .. i.description .. ')'
        end, custom_mappings),
        ' ╱ '
      )
  end
  return prompt
end

if is_available then
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  ---@param paths string[]
  ---@param cb fun(value:string):nil
  ---@param custom_mappings KeyMapping[]|nil
  function M.select_root_dir_path(paths, cb, custom_mappings)
    pickers
      .new({}, {
        prompt_title = get_prompt('Select Root Dir', custom_mappings),
        finder = finders.new_table({ results = paths }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          if custom_mappings then
            for _, mapping in ipairs(custom_mappings) do
              local key = remap_ctrl(mapping.key)
              print(mapping.key)
              print(key)
              map('i', key, function()
                actions.close(prompt_bufnr)
                cb(mapping.value)
              end)
              map('n', key, function()
                actions.close(prompt_bufnr)
                cb(mapping.value)
              end)
            end
          end
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if cb then
              cb(selection[1] or selection.value)
            end
          end)
          return true
        end,
      })
      :find()
  end

  ---@param venvs string[]
  ---@param cb fun(value:string):nil
  ---@param custom_mappings KeyMapping[]|nil
  function M.select_venv_path(venvs, cb, custom_mappings)
    pickers
      .new({}, {
        prompt_title = get_prompt('Select Virtual Env', custom_mappings),
        finder = finders.new_table({ results = venvs }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          if custom_mappings then
            for _, mapping in ipairs(custom_mappings) do
              local key = remap_ctrl(mapping.key)
              map('i', key, function()
                actions.close(prompt_bufnr)
                cb(mapping.value)
              end)
              map('n', key, function()
                actions.close(prompt_bufnr)
                cb(mapping.value)
              end)
            end
          end
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if cb then
              cb(selection[1] or selection.value)
            end
          end)
          return true
        end,
      })
      :find()
  end
end

return M
