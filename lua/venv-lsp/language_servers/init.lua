local pyright = require('venv-lsp.language_servers.pyright')
local basedpyright = require('venv-lsp.language_servers.basedpyright')
local pyrefly = require('venv-lsp.language_servers.pyrefly')

---@type table<string, table>
return {
  pyright = pyright,
  basedpyright = basedpyright,
  pyrefly = pyrefly,
  -- TODO: add others
}
