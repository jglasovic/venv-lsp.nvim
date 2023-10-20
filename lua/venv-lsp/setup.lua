local util = require 'venv-lsp.util'
local poetry = require 'venv-lsp.venv_managers.poetry'

local M = {}

function M._get_virtualenv_path(path)
  if poetry.should_use(path) then
    return util.with_cache(poetry.get_virtualenv_path, 'virtualenv_path', true)(path)
  end
  -- TODO: add other checks to support other virtualenv managers
  -- reset LRU
  util._reset_LRU()
  return nil
end

function M._set_virtualenv_vars(envvars, virtualenv_path)
  if not envvars then
    envvars = {}
  end
  -- always override VIRTUAL_ENV var even if it is explicitly added
  envvars.VIRTUAL_ENV = virtualenv_path

  if not envvars.PATH then
    -- TODO: could also cache
    envvars.PATH = os.getenv('PATH')
  end
  -- append to PATH
  -- TODO: fix for different systems (working on macos)
  envvars.PATH = virtualenv_path .. '/bin:' .. envvars.PATH
  return envvars
end

-- lspconfig override
function M._lspconfig_modify_setup(config)
  local _setup = config.setup
  config.setup = function(opts)
    if not opts then
      opts = {}
    end
    local _on_new_config = opts.on_new_config
    opts.on_new_config = function(new_config, root_dir)
      if _on_new_config then
        _on_new_config(new_config, root_dir)
      end

      local virtualenv_path = M._get_virtualenv_path(root_dir)
      if not virtualenv_path then
        return opts
      end

      if not new_config.cmd_env then
        new_config.cmd_env = {}
      end
      new_config.cmd_env = M._set_virtualenv_vars(new_config.cmd_env, virtualenv_path)
    end
    return _setup(opts)
  end
  return config
end

-- null-ls override
function M._null_ls_modify_builtin_with_fn(builtin)
  local _with = builtin.with
  builtin.with = function(opts)
    local _env = opts.env
    opts.env = function(...)
      local env = {}
      if type(_env) == "function" then
        env = _env(...)
      else
        env = _env
      end
      -- null-ls always runs after other main lsp client
      -- using LRU saved venv for the buffer
      local virtualenv_path = util.cache_LRU
      if not virtualenv_path then
        return env
      end
      return M._set_virtualenv_vars(env, virtualenv_path)
    end
    return _with(opts)
  end
  return builtin
end

function M._null_ls_modify_builtin(null_ls, type)
  local metatable = getmetatable(null_ls.builtins[type])
  local mt_d = {}
  function mt_d:__index(k)
    local result = metatable:__index(k)
    local filetypes = vim.tbl_get(result, 'filetypes')
    if not filetypes or not util.list_contains(filetypes, 'python') then
      return result
    end
    result = M._null_ls_modify_builtin_with_fn(result)
    -- call with to overwrite
    return result.with({})
  end
  setmetatable(null_ls.builtins[type], mt_d)
end

function M.inject_to_null_ls(null_ls)
  -- TODO: add other 
  M._null_ls_modify_builtin(null_ls, 'diagnostics')
  M._null_ls_modify_builtin(null_ls, 'formatting')
end

function M.inject_to_lspconfig(lspconfig)
  local lspconfig_metatable = getmetatable(lspconfig)
  -- create new metatable
  local mt = {}
  function mt:__index(k)
    local config = lspconfig_metatable:__index(k)
    local filetypes = vim.tbl_get(config, 'document_config', 'default_config', 'filetypes')
    if not filetypes or not util.list_contains(filetypes, 'python') then
      return config
    end
    return M._lspconfig_modify_setup(config)
  end

  setmetatable(lspconfig, mt)
end

function M.init()
  if M.initialized then
    return
  end
  local success_lsp_config, lspconfig = pcall(require, 'lspconfig')
  if not success_lsp_config then
    vim.notify(
      string.format(
        '[venv-lsp] Missing "lspconfig"!'),
      vim.log.levels.WARN
    )
    return
  end

  M.inject_to_lspconfig(lspconfig)
  local success_null_ls, null_ls = pcall(require, 'null-ls')
  if success_null_ls then
    M.inject_to_null_ls(null_ls)
  end
  M.initialized = true
end

return { init = M.init }
