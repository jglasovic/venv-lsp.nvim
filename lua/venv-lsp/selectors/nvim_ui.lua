local M = {
  is_available = true,
}

function M.select_venv_path(venvs, cb)
  vim.ui.select(venvs, {
    prompt = 'Select virtualenv path: ',
  }, function(virtualenv_path)
    if not virtualenv_path or virtualenv_path == '' then
      cb(nil)
    end
    cb(virtualenv_path)
  end)
end

function M.select_root_dir_path(default_root_dir, cb)
  vim.ui.input(
    { prompt = 'Add root_dir: ', default = default_root_dir },
    ---@param root_dir string|nil
    function(root_dir)
      if not root_dir or root_dir == '' then
        return cb(nil)
      end
      return cb(root_dir)
    end
  )
end

return M
