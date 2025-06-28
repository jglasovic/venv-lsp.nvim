local uv = (vim.uv or vim.loop)

local M = {}

-- Execute a shell command and return output as a table of lines
---@param cmd string
---@param cwd string|nil
---@return table|nil, integer|nil
function M.exec(cmd, cwd)
  if cwd then
    cmd = string.format('cd %s && %s', vim.fn.shellescape(cwd), cmd)
  end
  local result = vim.fn.systemlist(cmd)
  local code = vim.v.shell_error
  if code ~= 0 then
    return result, code
  end
  return result
end

-- Execute a shell command and return the full output as a string
---@param cmd string
---@param cwd string|nil
---@return string|nil, integer|nil
function M.exec_str(cmd, cwd)
  local result, code = M.exec(cmd, cwd)
  if code ~= nil and code ~= 0 then
    return nil, code
  end
  if type(result) == 'table' then
    return table.concat(result, '\n')
  end
  return result
end

-- Asynchronously execute a shell command, call cb(output, code)
---@param cmd string
---@param args table|nil
---@param cwd string|nil
---@param cb fun(data: string, code: integer)
---@return nil
function M.exec_async(cmd, args, cwd, cb)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  local output = {}
  local handle
  handle = uv.spawn(cmd, {
    args = args,
    stdio = { nil, stdout, stderr },
    cwd = cwd,
  }, function(code)
    if stdout then
      stdout:close()
    end
    if stderr then
      stderr:close()
    end
    handle:close()
    cb(table.concat(output, ''), code)
  end)
  if stdout then
    stdout:read_start(function(err, data)
      assert(not err, err)
      if data then
        table.insert(output, data)
      end
    end)
  end
  if stderr then
    stderr:read_start(function(err, data)
      assert(not err, err)
      if data then
        table.insert(output, data)
      end
    end)
  end
end

return M
