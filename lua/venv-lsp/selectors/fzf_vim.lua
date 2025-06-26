local fzf_run = vim.fn['fzf#run']
local fzf_wrap = vim.fn['fzf#wrap']

local M = {
  is_available = not not fzf_run,
}

function M.select_root_dir_path(default_root_dir, cb)
  fzf_run(fzf_wrap({
    source = 'find ' .. vim.fn.shellescape(default_root_dir) .. ' -type d',
    sink = cb,
    options = { '--prompt=Select Directory:', '--no-multi' },
  }))
end

function M.select_venv_path(venvs, cb)
  fzf_run(fzf_wrap({
    source = venvs,
    sink = cb,
    options = { '--prompt=Select Virtual Env:', '--no-multi' },
  }))
end

return M
