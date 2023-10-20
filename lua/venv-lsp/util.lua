local uv = vim.loop
local M = {}

function M.list_contains(list, item)
  for _, value in ipairs(list) do
    if value == item then
      return true
    end
  end
  return false
end

function M.path_exists(filename)
  local stat = uv.fs_stat(filename)
  return stat and stat.type or false
end

M.cache_map = {}
M.cache_LRU = nil

M.with_cache = function(cb, cache_key, set_LRU)
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
    if set_LRU then
      M.cache_LRU = M.cache_map[cache_key][input_key]
    end
    return M.cache_map[cache_key][input_key]
  end
end

function M._reset_LRU()
  M.cache_LRU = nil
end

function M._reset_all()
  M.cache_map = {}
end

return M
