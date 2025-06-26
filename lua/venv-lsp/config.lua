local path = require('venv-lsp.common.path')
local logger = require('venv-lsp.common.logger')

---@class Config
---@field cache_json_path string|nil
---@field disable_cache boolean|nil
---@field disable_auto_venv boolean|nil
local default_config = {
  cache_json_path = path.join(vim.fn.stdpath('cache'), 'venv_lsp', 'cache.json'),
  -- By default cache is active
  disable_cache = false,
  -- By default auto venv detection is active
  disable_auto_venv = false,
}

local M = {
  _config = default_config,
}

---@param config Config
---@return nil
M.update = function(config)
  if type(config) ~= 'table' then
    logger.warn('Provided `config` is not a valid `table` type! Using the default config!')
    return
  end
  local cache_json_path = vim.tbl_get(config, 'cache_json_path')

  -- if updating cache_json_path, validate path
  if cache_json_path then
    if not path.is_ext(cache_json_path, '.json') then
      config.cache_json_path = M._cache_json_path:get()
      logger.warn('Provided `cache_json_path` is not a valid json, using fallback path ' .. config.cache_json_path)
    end
  end

  M._config = vim.tbl_deep_extend('force', M._config, config)
end

---@return Config
M.get = function()
  return M._config
end

return M
