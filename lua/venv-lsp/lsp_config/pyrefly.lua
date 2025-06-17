local venv = require("venv-lsp.venv")
local M = {}

M.update_config = function(config, virtualenv_path)
	-- there are some problems with using tbl_extand or tbl_deep_extand so appending pythonPath like this:
	config.settings = config.settings or {}
	config.settings.python = config.settings.python or {}
	config.settings.python.pythonPath = venv.get_python_path(virtualenv_path)
end

M.default_config = {
	cmd = { "pyrefly", "lsp" },
	filetypes = { "python" },
	settings = {},
	root_markers = {
		"pyrefly.toml",
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		"pyvenv.cfg",
		".git",
	},
	on_exit = function(code, _, _)
		vim.notify("Closing Pyrefly LSP exited with code: " .. code, vim.log.levels.INFO)
	end,
}
return M
