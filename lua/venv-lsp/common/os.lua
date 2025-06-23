local uv = (vim.uv or vim.loop)

local M = {
  ---@type boolean
  is_win = uv.os_uname().version:match('Windows'),
}

---@param env string
---@return string|nil
function M.get_env(env)
  return vim.env[env]
end

---@param env string
---@param value string
---@return nil
function M.set_env(env, value)
  vim.env[env] = value
end

return M
