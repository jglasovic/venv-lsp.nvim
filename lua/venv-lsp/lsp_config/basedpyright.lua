local venv = require('venv-lsp.venv')
local M = {}

M.update_config = function(config, virtualenv_path)
  -- there are some problems with using tbl_extand or tbl_deep_extand so appending pythonPath like this:
  config.settings = config.settings or {}
  config.settings.python = config.settings.python or {}
  config.settings.python.pythonPath = venv.get_python_path(virtualenv_path)
end

M.default_config = {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
    'pyvenv.cfg',
    '.git',
  },
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'openFilesOnly',
      },
    },
  },
}

return M
