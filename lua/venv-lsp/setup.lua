local utils = require("venv-lsp.utils")
local venv = require("venv-lsp.venv")
local commands = require("venv-lsp.commands")
local lsp_configs = require("venv-lsp.lsp_config")
local config = require("venv-lsp.config")
local cache = require("venv-lsp.cache")
local logger = require("venv-lsp.logger")

local M = {}

function M._update_config_wrapper(update_config)
	return function(new_config, root_dir)
		local config_dict = config.get()
		if config_dict.disabled_auto_venv then
			return
		end
		-- save current active venv
		local previous_venv = vim.env.VIRTUAL_ENV
		-- deactivate previous venv before searching for the new one
		venv.deactivate_virtualenv()
		-- check if the cache exists
		local virtualenv_path = cache.get_venv(root_dir)
		if not virtualenv_path then
			virtualenv_path = venv.get_virtualenv_path(root_dir)
			if virtualenv_path then
				cache.set_venv(root_dir, virtualenv_path)
			end
		end
		if not virtualenv_path then
			-- use previous venv if exists
			virtualenv_path = previous_venv
		end
		-- set and activate if venv exists
		if virtualenv_path then
			update_config(new_config, virtualenv_path)
			venv.activate_virtualenv(virtualenv_path)
			-- store venv_path value for on attach to save it on buffer
			new_config._custom_venv_path = virtualenv_path
		end
	end
end

function M._custom_on_attach(original_on_attach)
	return function(client, bufnr)
		if original_on_attach then
			original_on_attach(client, bufnr)
		end
		local venv_path = vim.tbl_get(client, "config", "_custom_venv_path")
		if venv_path then
			vim.api.nvim_buf_set_var(bufnr, "VIRTUAL_ENV", venv_path)
			venv.activate_buffer()
		end
	end
end

function M._custom_before_init(original_before_init, update_config)
	return function(params, client_config)
		if original_before_init then
			original_before_init(params, client_config)
		end
		update_config(client_config, params.rootPath)
	end
end

function M._custom_root_dir(original_root_dir, root_markers)
	return function(bufnr, cb)
		-- try if buffer is for any cached venv root_dir
		local root_dir = cache.get_root_dir_by_bufnr(bufnr)
		if root_dir then
			return cb(root_dir)
		end

		if original_root_dir then
			return original_root_dir(bufnr, cb)
		end

		root_dir = vim.fs.root(bufnr, root_markers)
		return cb(root_dir)
	end
end

function M._init_lsp() -- for nvim v0.11
	for name, lsp in pairs(lsp_configs) do
		local lsp_config = vim.lsp.config[name]
		-- use default config if one is missing -- no need for lspconfig plugin anymore
		if not lsp_config then
			lsp_config = lsp.default_config
		end
		-- not working correctly if the settings are missing from the config
		if not lsp_config.settings then
			lsp_config.settings = {}
		end

		lsp_config.on_attach = M._custom_on_attach(lsp_config.on_attach)
		lsp_config.before_init =
			M._custom_before_init(lsp_config.before_init, M._update_config_wrapper(lsp.update_config))
		lsp_config.root_dir = M._custom_root_dir(lsp_config.root_dir, lsp_config.root_markers)

		vim.lsp.config(name, lsp_config)
	end
	commands.init_auto_venv()
end

--- @deprecated use `vim.lsp.config` in Nvim 0.11+ instead.
function M._custom_lspconfig_root_dir(original_root_dir, util, root_markers)
	return function(fname)
		-- try if buffer is for any cached venv root_dir
		local root_dir = cache.get_root_dir_by_fname(fname)
		if root_dir then
			return root_dir
		end
		if original_root_dir then
			return original_root_dir(fname)
		end
		return util.root_pattern(unpack(root_markers))(fname)
	end
end

--- @deprecated use `vim.lsp.config` in Nvim 0.11+ instead.
function M._init_lspconfig(lspconfig_pkg)
	local on_setup = function(client_config)
		local lsp = lsp_configs[client_config.name]
		if lsp then
			client_config.on_new_config = lspconfig_pkg.util.add_hook_after(
				client_config.on_new_config,
				M._update_config_wrapper(lsp.update_config)
			)
			client_config.on_attach = M._custom_on_attach(client_config.on_attach)
			client_config.root_dir = M._custom_lspconfig_root_dir(
				client_config.root_dir,
				lspconfig_pkg.util,
				lsp.default_config.root_markers
			)
			commands.init_auto_venv()
		end
	end

	lspconfig_pkg.util.on_setup = lspconfig_pkg.util.add_hook_after(lspconfig_pkg.util.on_setup, on_setup)
end

function M.setup(user_config)
	if M.initialized then
		return
	end
	-- setup config
	if user_config then
		config.update(user_config)
	end
	-- setup cache
	cache.init()
	-- for nvim v0.11
	if utils.nvim_is_0_11_or_higher then
		M._init_lsp()
	end

	local success_lsp_config, lspconfig_pkg = pcall(require, "lspconfig")
	if not success_lsp_config and not utils.nvim_is_0_11_or_higher then
		logger.error("Missing required `lspconfig`!")
		return
	end
	if success_lsp_config then
		M._init_lspconfig(lspconfig_pkg)
	end
	commands.init_user_cmd()
	M.initialized = true
end

function M.get_active_virtualenv()
	local virtualenv = vim.env.VIRTUAL_ENV
	if virtualenv then
		local _, _, venv_name = string.find(virtualenv, "[/\\]([^/\\]+)$")
		return venv_name or ""
	end
	return ""
end

return M
