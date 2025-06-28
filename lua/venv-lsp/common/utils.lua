local M = {}

---@param str string
---@param what string
---@param with string
---@return string
function M.str_replace(str, what, with)
  what = string.gsub(what, '[%(%)%.%+%-%*%?%[%]%^%$%%]', '%%%1') -- escape pattern
  with = string.gsub(with, '[%%]', '%%%%') -- escape replacement
  local result = string.gsub(str, what, with)
  return result
end

-- test helper
---@generic T
---@param fn fun(...): T
---@param ... any
---@return T
function M.timeit(fn, ...)
  local start = vim.loop.hrtime()
  local result = fn(...)
  local elapsed = (vim.loop.hrtime() - start) / 1e6 -- ms
  print(string.format('Time: %.3f ms', elapsed))
  return result
end

return M
