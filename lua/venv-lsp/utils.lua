local uv = (vim.uv or vim.loop)

local M = {
  _cache_map = {},
  _iswin = vim.uv.os_uname().version:match 'Windows',
  _path_separator = package.config:sub(1, 1),
  nvim_is_0_11_or_higher = (function()
    local version = vim.version()
    -- Logic for Neovim 0.11 or higher
    return version.major > 0 or (version.major == 0 and version.minor >= 11)
  end)()

}

function M.path_exists(filename)
  local stat = uv.fs_stat(filename)
  return stat and stat.type or false
end

function M.path_join(...)
  return table.concat({ ... }, M._path_separator)
end

function M.str_replace(str, what, with)
  what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
  with = string.gsub(with, "[%%]", "%%%%")                       -- escape replacement
  return string.gsub(str, what, with)
end

function M.normalize_dir_path(dir_path)
  local expanded = vim.fn.expand(dir_path)
  local dir = expanded:gsub("[/\\]+$", "")
  return dir
end

-- in memory cache
function M.with_cache(cb, cache_key)
  if not M._cache_map[cache_key] then
    M._cache_map[cache_key] = {}
  end
  return function(input_key)
    if M._cache_map[cache_key][input_key] == nil then
      local result = cb(input_key)
      if not result then
        return nil
      end
      M._cache_map[cache_key][input_key] = result
    end
    return M._cache_map[cache_key][input_key]
  end
end

-- support windows
M.venv_path_suffix = M._iswin and "Scripts;" or 'bin:'
M.python_path_suffix = M._iswin and M.path_join('Scripts', 'python.exe') or M.path_join('bin', 'python')

return M
