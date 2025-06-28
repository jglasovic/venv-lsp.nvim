local commands = require('venv-lsp.commands')
local language_servers = require('venv-lsp.language_servers')
local cache = require('venv-lsp.cache')
local hooks = require('venv-lsp.hooks')

---@param default_on_attach elem_or_list<fun(client: vim.lsp.Client, bufnr: integer)>|nil
---@return elem_or_list<fun(client: vim.lsp.Client, bufnr: integer)>|nil
local on_attach = function(default_on_attach)
  if type(default_on_attach) == 'table' then
    return table.insert(default_on_attach, hooks.on_attach)
  end
  if type(default_on_attach) == 'function' then
    return { default_on_attach, hooks.on_attach }
  end

  return hooks.on_attach
end

---@param default_before_init nil|fun(params: lsp.InitializeParams, config: vim.lsp.ClientConfig):nil
---@param on_new_config fun(config: vim.lsp.ClientConfig, root_dir):nil
---@return fun(params: lsp.InitializeParams, config: vim.lsp.ClientConfig):nil
local before_init = function(default_before_init, on_new_config)
  return function(params, client_config)
    if default_before_init then
      default_before_init(params, client_config)
    end
    on_new_config(client_config, params.rootPath)
  end
end

---@param default_root_dir (string|fun(bufnr: integer, cb: fun(root_dir?: string)))?
---@param root_markers table
---@return fun(bufnr: integer, cb: fun(root_dir?: string))
local root_dir = function(default_root_dir, root_markers)
  return function(bufnr, cb)
    local root_dir = cache.get_root_dir_by_bufnr(bufnr)
    if root_dir then
      return cb(root_dir)
    end
    if default_root_dir then
      if type(default_root_dir) == 'string' then
        return cb(default_root_dir)
      end
      return default_root_dir(bufnr, cb)
    end
    root_dir = vim.fs.root(bufnr, root_markers)
    return cb(root_dir)
  end
end

local M = {}

function M.setup() -- for nvim v0.11
  for name, ls in pairs(language_servers) do
    local lspconfig = vim.lsp.config[name]
    -- use default config if one is missing -- no need for lspconfig plugin anymore
    if not lspconfig then
      lspconfig = ls.default_config
    end
    -- not working correctly if the settings are missing from the config
    if not lspconfig.settings then
      lspconfig.settings = {}
    end

    local on_new_config = hooks.get_on_new_config(ls.update_config)

    lspconfig.on_attach = on_attach(lspconfig.on_attach)
    lspconfig.before_init = before_init(lspconfig.before_init, on_new_config)
    lspconfig.root_dir = root_dir(lspconfig.root_dir, lspconfig.root_markers)

    vim.lsp.config(name, lspconfig)
  end
  commands.init_auto_venv()
end

return M
