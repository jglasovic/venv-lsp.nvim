local pyright = require("venv-lsp.lsp_config.pyright")
local basedpyright = require("venv-lsp.lsp_config.basedpyright")
local pyrefly = require("venv-lsp.lsp_config.pyrefly")

return {
	pyright = pyright,
	basedpyright = basedpyright,
	pyrefly = pyrefly,
	-- TODO: add others
}
