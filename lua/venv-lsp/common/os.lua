local uv = (vim.uv or vim.loop)
local sysname = uv.os_uname().sysname:lower()
local iswin = not not (sysname:find('windows') or sysname:find('mingw'))

local M = {
  ---@type boolean
  is_win = iswin,
}

---@param env string
---@return string|nil
function M.get_env(env)
  return vim.env[env]
end

---@param env string
---@param value string|nil
---@return nil
function M.set_env(env, value)
  vim.env[env] = value
end

return M
