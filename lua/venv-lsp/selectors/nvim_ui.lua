local M = {
  is_available = true,
}

function M.select_root_dir_path(paths, cb)
  vim.ui.select(paths, {
    prompt = 'Select Root Dir: ',
  }, function(root_path)
    if not root_path or root_path == '' then
      cb(nil)
    end
    cb(root_path)
  end)
end

function M.select_venv_path(venvs, cb)
  vim.ui.select(venvs, {
    prompt = 'Select Virtual Env: ',
  }, function(virtualenv_path)
    if not virtualenv_path or virtualenv_path == '' then
      cb(nil)
    end
    cb(virtualenv_path)
  end)
end

return M
