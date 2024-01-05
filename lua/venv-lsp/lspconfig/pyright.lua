local venv = require 'venv-lsp.venv'
local M = {}

function M.update_config(config, virtualenv_path)
  config.settings.python.pythonPath = venv.get_python_path(virtualenv_path)
end

return M
