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
M._LRU = nil

M.with_cache = function(cb, cache_key)
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

function M.set_LRU(venv)
  M._LRU = venv
end

function M.get_LRU()
  return M._LRU
end

function M.reset_LRU()
  M.cache_LRU = nil
end

return M
