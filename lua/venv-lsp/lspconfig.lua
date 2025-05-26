local pyright = require 'venv-lsp.lspconfig.pyright'
local basedpyright = require 'venv-lsp.lspconfig.basedpyright'
local pyrefly = require 'venv-lsp.lspconfig.pyrefly'

return {
  ['pyright'] = pyright,
  ['basedpyright'] = basedpyright,
  ['pyrefly'] = pyrefly
  -- TODO: add others
}
