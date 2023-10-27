local venv = require 'venv-lsp.venv'
local M = {}

function M.on_new_config(new_config, root_dir)
  venv.deactivate_virtualenv()
  local virtualenv_path = venv.get_virtualenv_path(root_dir)
  if virtualenv_path then
    venv.activate_virtualenv(virtualenv_path)
    new_config.settings.python.pythonPath = venv.get_python_path(virtualenv_path)
  end
end

return M
