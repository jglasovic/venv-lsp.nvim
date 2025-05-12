local venv = require 'venv-lsp.venv'
local M = {}

function M.update_config(config, virtualenv_path)
  -- there are some problems with using tbl_extand or tbl_deep_extand so appending pythonPath like this:
  config.settings = config.settings or {}
  config.settings.python = config.settings.python or {}
  config.settings.python.pythonPath = venv.get_python_path(virtualenv_path)
end

return M
