local venv_lsp_setup = require('venv-lsp.setup')
local common_os = require('venv-lsp.common.os')

local M = {}

---@return string
function M.active_virtualenv()
  local virtualenv = common_os.get_env('VIRTUAL_ENV')
  if virtualenv then
    return vim.fn.fnamemodify(virtualenv, ':t')
  end
  return ''
end

M.setup = venv_lsp_setup.setup
--- @deprecated use `setup(<config: table|nil>)` instead of `init(<config: table|nil>)`
M.init = venv_lsp_setup.setup

return M
