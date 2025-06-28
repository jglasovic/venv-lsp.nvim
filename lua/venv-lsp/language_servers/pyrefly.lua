local M = {}

---@param config table
---@param python_path string
---@return nil
function M.update_config(config, python_path)
  -- there are some problems with using tbl_extand or tbl_deep_extand so appending pythonPath like this:
  config.settings = config.settings or {}
  config.settings.python = config.settings.python or {}
  config.settings.python.pythonPath = python_path
end

M.default_config = {
  cmd = { 'pyrefly', 'lsp' },
  filetypes = { 'python' },
  settings = {},
  root_markers = {
    'pyrefly.toml',
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyvenv.cfg',
    '.git',
  },
  on_exit = function(code, _, _)
    vim.notify('Closing Pyrefly LSP exited with code: ' .. code, vim.log.levels.INFO)
  end,
}

return M
