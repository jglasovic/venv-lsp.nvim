local uv = (vim.uv or vim.loop)


local _is_0_11_or_higher_nvim_version = function()
  local version = vim.version()
  -- Logic for Neovim 0.11.0 or higher
  return version.major > 0 or (version.major == 0 and version.minor >= 11)
end

local M = { cache_map = {} }

function M.path_exists(filename)
  local stat = uv.fs_stat(filename)
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

function M.normalize_dir_path(dir_path)
  local expanded = vim.fn.expand(dir_path)
  local dir = expanded:gsub("[/\\]+$", "")
  return dir
end

-- in memory cache
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

M.path_separator = package.config:sub(1, 1)
M.is_0_11_or_higher_nvim_version = _is_0_11_or_higher_nvim_version()
-- support for windows
M.is_windows = uv.os_uname().sysname == "Windows_NT"
M.venv_path_suffix = M.is_windows and "Scripts;" or 'bin:'
M.python_path_suffix = M.is_windows and M.path_join('Scripts', 'python.exe') or M.path_join('bin', 'python')

return M
