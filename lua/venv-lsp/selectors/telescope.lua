local is_available = pcall(require, 'telescope')
local M = {
  is_available = is_available,
}

if is_available then
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  -- TODO: add faster way for searching dirs
  local function scan_dirs(root)
    local dirs = {}
    local scan = require('plenary.scandir')
    for _, dir in ipairs(scan.scan_dir(root, { only_dirs = true, respect_gitignore = true, depth = 5 })) do
      table.insert(dirs, dir)
    end
    return dirs
  end

  function M.select_root_dir_path(default_root_dir, cb)
    local dirs = scan_dirs(default_root_dir)
    pickers
      .new({}, {
        prompt_title = 'Select Directory',
        finder = finders.new_table({ results = dirs }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
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

  function M.select_venv_path(venvs, cb)
    pickers
      .new({}, {
        prompt_title = 'Select Virtual Env',
        finder = finders.new_table({ results = venvs }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
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
