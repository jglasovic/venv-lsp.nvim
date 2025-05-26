local pyright = require 'venv-lsp.lspconfig.pyright'
local basedpyright = require 'venv-lsp.lspconfig.basedpyright'

return {
  ['pyright'] = pyright,
  ['basedpyright'] = basedpyright
  -- TODO: add others
}
