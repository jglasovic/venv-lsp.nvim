local venv_lsp_setup = require('venv-lsp.setup')
local venv = require('venv-lsp.venv')

local M = {}

M.active_virtualenv = venv.get_active_virtualenv
M.setup = venv_lsp_setup.setup

--- @deprecated use `setup(<config: table|nil>)` instead of `init(<config: table|nil>)`
M.init = venv_lsp_setup.setup

return M
