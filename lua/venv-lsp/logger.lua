local prefix = '[venv-lsp]: '

---@param log_level integer
local wrapper_func = function(log_level)
  ---@param msg string
  return function(msg)
    return vim.schedule(function()
      vim.notify(prefix .. msg, log_level)
    end)
  end
end

return {
  info = wrapper_func(vim.log.levels.INFO),
  warn = wrapper_func(vim.log.levels.WARN),
  error = wrapper_func(vim.log.levels.ERROR),
}
