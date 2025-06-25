local language_servers = require('venv-lsp.language_servers')
local hooks = require('venv-lsp.hooks')
local cache = require('venv-lsp.cache')
local commands = require('venv-lsp.commands')

local lspconfig = require('lspconfig')

local unpack = table.unpack or unpack

local on_new_config = function(default_on_new_config, custom_on_new_config)
  return function(config, root_dir)
    if default_on_new_config then
      default_on_new_config(config, root_dir)
    end
    custom_on_new_config(config, root_dir)
  end
end

---@param default_root_dir fun(fname: string): string|nil
---@param root_markers table
---@return fun(fname:string):string|nil
local root_dir = function(default_root_dir, root_markers)
  return function(fname)
    -- try if buffer is for any cached venv root_dir
    local root_dir = cache.get_root_dir_by_fname(fname)
    if root_dir then
      return root_dir
    end
    if default_root_dir then
      return default_root_dir(fname)
    end
    return lspconfig.util.root_pattern(unpack(root_markers))(fname)
  end
end

---@param default_on_attach nil|fun(client: table, bufnr: integer):nil
local on_attach = function(default_on_attach)
  return function(client, bufnr)
    if default_on_attach then
      default_on_attach(client, bufnr)
    end
    hooks.on_attach(client, bufnr)
  end
end

local on_setup = function(config)
  local lsp = language_servers[config.name]
  if lsp then
    local update_config = lsp.update_config
    local root_markers = lsp.update_config
    local custom_on_new_config = hooks.get_on_new_config(update_config)

    config.on_new_config = on_new_config(config.on_new_config, custom_on_new_config)
    config.on_attach = on_attach(config.on_attach)
    config.root_dir = root_dir(config.root_dir, root_markers)

    commands.init_auto_venv()
  end
end

local M = {}

---@return nil
--- @deprecated use `vim.lsp.config` in Nvim 0.11+ instead.
function M.setup()
  lspconfig.util.on_setup = lspconfig.util.add_hook_after(lspconfig.util.on_setup, on_setup)
end

return M
