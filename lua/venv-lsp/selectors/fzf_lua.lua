local is_available = pcall(require, 'fzf-lua')

local M = { is_available = is_available }

if is_available then
  local fzf_lua = require('fzf-lua')
  function M.select_root_dir_path(paths, cb)
    fzf_lua.fzf_exec(paths, {
      prompt = 'Select Root Dir: ',
      actions = {
        ['default'] = function(selected)
          if cb then
            cb(selected[1])
          end
        end,
      },
      multi = false,
    })
  end

  function M.select_venv_path(venvs, cb)
    fzf_lua.fzf_exec(venvs, {
      prompt = 'Select Virtual Env: ',
      actions = {
        ['default'] = function(selected)
          if cb then
            cb(selected[1])
          end
        end,
      },
      multi = false,
    })
  end
end

return M
