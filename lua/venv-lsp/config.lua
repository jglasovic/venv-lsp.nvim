local fallback_cache_json_path = vim.fn.stdpath("cache") .. '/venv_lsp/cache.json'

local M = {
  config = {
    cache_json_path = fallback_cache_json_path
  },
  fallback_cache_json_path = fallback_cache_json_path
}

M.update_config = function(config)
  if type(config) == "table" then
    M.config = vim.tbl_deep_extend("keep", config, M.config)
  end
end

return M
