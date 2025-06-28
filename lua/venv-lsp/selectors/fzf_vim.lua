local fzf_run = vim.fn['fzf#run']
local fzf_wrap = vim.fn['fzf#wrap']

local M = {
  is_available = not not fzf_run,
}

function M.select_root_dir_path(paths, cb)
  fzf_run(fzf_wrap({
    source = paths,
    sink = cb,
    options = { '--prompt=Select Root Dir: ', '--no-multi' },
  }))
end

function M.select_venv_path(venvs, cb)
  fzf_run(fzf_wrap({
    source = venvs,
    sink = cb,
    options = { '--prompt=Select Virtual Env: ', '--no-multi' },
  }))
end

return M
