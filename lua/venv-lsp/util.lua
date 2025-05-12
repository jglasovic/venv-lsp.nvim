local uv = vim.loop
local M = { cache_map = {} }

function M.path_exists(filename)
  local stat = uv.fs_stat(filename)
  return stat and stat.type or false
end

function M.replace(str, what, with)
  what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
  with = string.gsub(with, "[%%]", "%%%%")                       -- escape replacement
  return string.gsub(str, what, with)
end

function M.with_cache(cb, cache_key)
  if not M.cache_map[cache_key] then
    M.cache_map[cache_key] = {}
  end
  return function(input_key)
    if M.cache_map[cache_key][input_key] == nil then
      local result = cb(input_key)
      if not result then
        return nil
      end
      M.cache_map[cache_key][input_key] = result
    end
    return M.cache_map[cache_key][input_key]
  end
end

function M.is_0_11_nvim_version_or_higher()
  local version = vim.version()
  -- Logic for Neovim 0.11.0 or higher
  return version.major > 0 or (version.major == 0 and version.minor >= 11)
end

return M
