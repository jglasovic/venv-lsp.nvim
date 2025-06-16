local logger = require('venv-lsp.logger')
local fallback_cache_json_path = vim.fn.stdpath("cache") .. '/venv_lsp/cache.json'

local M = {
  _config = {
    cache_json_path = fallback_cache_json_path,
    -- By default auto venv detection is active
    disabled_auto_venv = false,
  },
}

---@return boolean
M._validate_json_path = function(json_path)
  -- check if the path is with json ext
  if json_path:sub(-5) ~= ".json" then
    logger.error("`cache_json_path` value is not a valid '.json' file :" .. json_path)
    return false
  end
  return true
end


---@return nil
M.update = function(config)
  if type(config) ~= "table" then
    logger.warn("Provided `config` is not a valid `table` type! Using the default config!")
    return
  end
  local json_path = vim.get(config, 'cache_json_path')
  if json_path and not M._validate_json_path(json_path) then
    config.cache_json_path = fallback_cache_json_path
    logger.log("Using fallback path " .. fallback_cache_json_path, vim.log.levels.WARN)
  end
  M._config = vim.tbl_deep_extend("keep", config, M._config)
end

---@return table
M.get = function()
  return M._config
end

M.set_disabled_auto_venv = function(value)
  if type(value) ~= "boolean" then
    logger.error("Wrong value type!")
    return
  end
  M._config.disabled_auto_venv = value
end

return M
