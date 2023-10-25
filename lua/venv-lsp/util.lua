local uv = vim.loop
local M = { cache_map = {} }

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

function M.modify_metatable(tbl, modify)
  local _mt = getmetatable(tbl)
  local mt = {}
  function mt:__index(k)
    local item = _mt:__index(k)
    local result = modify(item)
    return result or item
  end

  setmetatable(tbl, mt)
end

return M
