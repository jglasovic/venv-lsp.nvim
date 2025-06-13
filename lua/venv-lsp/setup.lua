local utils = require 'venv-lsp.utils'
local venv = require 'venv-lsp.venv'
local commands = require 'venv-lsp.commands'
local lspconfig = require 'venv-lsp.lspconfig'
local config_utils = require('venv-lsp.config')
local cache = require('venv-lsp.cache')

local M = {}

function M._on_new_config(update_config)
  return function(new_config, root_dir)
    if commands.disabled_auto_venv then
      return
    end

    -- check if the cache exists
    local virtualenv_path
    local chached_venv_path = cache.get_venv(root_dir)
    if chached_venv_path then
      virtualenv_path = tostring(chached_venv_path)
    else
      local previous_venv = vim.env.VIRTUAL_ENV
      -- deactivate previous venv before searching for the new one
      venv.deactivate_virtualenv()
      local new_virtualenv_path = venv.get_virtualenv_path(root_dir)
      if new_virtualenv_path then
        cache.set_venv(root_dir, new_virtualenv_path)
      end
      -- if cannot find the new venv, fallback to the previous one
      virtualenv_path = new_virtualenv_path or previous_venv
    end
    -- set and activate if venv exists
    if virtualenv_path then
      update_config(new_config, virtualenv_path)
      venv.activate_virtualenv(virtualenv_path)
    end
  end
end

function M._init_lsp() -- for nvim v0.11
  for name, lsp in pairs(lspconfig) do
    local lsp_config = vim.lsp.config[name]
    -- use default config if one is missing -- no need for lspconfig plugin anymore
    if not lsp_config then
      lsp_config = lsp.default_config
    end
    -- not working correctly if the settings are missing from the config
    if not lsp_config.settings then
      lsp_config.settings = {}
    end

    local original_root_markers = lsp_config.root_markers or nil
    local original_root_dir = lsp_config.root_dir or nil
    local original_before_init = lsp_config.before_init or nil

    local custom_before_init = M._on_new_config(lsp.update_config)
    -- setup before_init
    lsp_config.before_init = function(params, config)
      if original_before_init then
        original_before_init(params, config)
      end
      custom_before_init(config, params.rootPath)
    end

    lsp_config.root_dir = function(bufnr, cb)
      local custom_cb = function(root_dir)
        -- check cache
        local mapped_root_dir = cache.get_root_dir(root_dir)
        cb(mapped_root_dir or root_dir)
      end
      if original_root_dir then
        return original_root_dir(bufnr, custom_cb)
      end
      local root_dir
      if original_root_markers then
        root_dir = vim.fs.root(bufnr, original_root_markers)
      end
      if not root_dir then
        root_dir = vim.fn.getcwd() -- fallback to cwd if missing
      end
      return custom_cb(root_dir)
    end
    vim.lsp.config(name, lsp_config)
  end
  commands.init_auto_venv()
end

function M._init_lspconfig()
  local lspconfig_pkg = require 'lspconfig'
  local on_setup = function(config)
    local lsp = lspconfig[config.name]
    if lsp then
      config.on_new_config = lspconfig_pkg.util.add_hook_after(config.on_new_config, M._on_new_config(lsp.update_config))
      commands.init_auto_venv()
    end
  end
  lspconfig_pkg.util.on_setup = lspconfig_pkg.util.add_hook_after(lspconfig_pkg.util.on_setup, on_setup)
end

function M.init(custom_config)
  if M.initialized then
    return
  end
  -- setup config
  config_utils.update_config(custom_config)
  -- setup cache
  cache.init()
  -- for nvim v0.11
  if utils.is_0_11_or_higher_nvim_version then
    M._init_lsp()
  else
    local success_lsp_config, _ = pcall(require, 'lspconfig')
    if not success_lsp_config then
      vim.notify('[venv-lsp] Missing "lspconfig"!', vim.log.levels.ERROR)
      return
    end
    M._init_lspconfig()
  end
  commands.init_user_cmd()
  M.initialized = true
end

function M.active_virtualenv()
  local virtualenv = vim.env.VIRTUAL_ENV
  if virtualenv then
    local _, _, venv_name = string.find(virtualenv, '[/\\]([^/\\]+)$')
    return venv_name or ''
  end
  return ''
end

return M
