local M = { cache_map = {} }

local _is_0_11_or_higher_nvim_version = function()
  local version = vim.version()
  -- Logic for Neovim 0.11.0 or higher
  return version.major > 0 or (version.major == 0 and version.minor >= 11)
end

M.is_windows = vim.loop.os_uname().sysname == "Windows_NT"
M.path_separator = package.config:sub(1, 1)
M.is_0_11_or_higher_nvim_version = _is_0_11_or_higher_nvim_version()

function M.path_exists(filename)
  local stat = vim.loop.fs_stat(filename)
  return stat and stat.type or false
end

function M.path_join(...)
  return table.concat({ ... }, M.path_separator)
end

function M.str_replace(str, what, with)
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

return M
