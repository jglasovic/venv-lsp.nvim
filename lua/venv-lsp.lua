local venv_lsp_setup = require 'venv-lsp.setup'

return { init = venv_lsp_setup.init, active_virtualenv = venv_lsp_setup.active_virtualenv }
