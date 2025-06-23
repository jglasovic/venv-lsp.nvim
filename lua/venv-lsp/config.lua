local Path = require('venv-lsp.common.path')
local logger = require('venv-lsp.logger')

local M = {
  _cache_json_path = Path:new(vim.fn.stdpath('cache'), 'venv_lsp', 'cache.json'),
  _config = {
    -- path set by user
    cache_json_path = nil,
    -- By default cache is active
    disable_cache = false,
    -- By default auto venv detection is active
    disable_auto_venv = false,
  },
}

function M.get_cache_json_path()
  M._cache_json_path:ensure_file_exists()
  return M._cache_json_path
end

---@param config table
---@return nil
M.update = function(config)
  if type(config) ~= 'table' then
    logger.warn('Provided `config` is not a valid `table` type! Using the default config!')
    return
  end

  -- if updating cache_json_path, validate path
  local cache_json_path_value = vim.tbl_get(config, 'cache_json_path')
  if cache_json_path_value then
    local cache_json_path = Path:new(cache_json_path_value)
    if cache_json_path:is_ext('.json') then
      M._cache_json_path = cache_json_path
    else
      config.cache_json_path = M._cache_json_path:get()
      logger.warn('Provided `cache_json_path` is not a valid json, using fallback path ' .. config.cache_json_path)
    end
  end

  M._config = vim.tbl_deep_extend('force', M._config, config)
end

---@return table
M.get = function()
  return M._config
end

---@param value boolean
---@return nil
M.set_disable_auto_venv = function(value)
  if type(value) ~= 'boolean' then
    logger.error('Wrong value type!')
    return
  end
  M._config.disable_auto_venv = value
end

return M
