local uv = (vim.uv or vim.loop)

local M = {}
---Read the contents of a file synchronously.
---@param path string
---@return string|nil content
---@return string|nil err
function M.read_file(path)
  local f, open_err = io.open(path, 'r')
  if not f then
    return nil, 'Cannot open file: ' .. path .. (open_err and (': ' .. open_err) or '')
  end
  local ok, content = pcall(f.read, f, '*a')
  f:close()
  if not ok then
    return nil, 'Error reading file: ' .. path
  end
  return content, nil
end

---Write contents to a file asynchronously.
---@param path string
---@param encoded string
---@param cb fun(err: string|nil, msg: string|nil): nil
function M.write_file_async(path, encoded, cb)
  uv.fs_open(path, 'w', 420, function(err_open, fd)
    if err_open or not fd then
      return cb('Cannot open file for writing :' .. path)
    end
    uv.fs_write(fd, encoded, -1, function(err_write)
      uv.fs_close(fd)
      if err_write then
        return cb('Error writing file ' .. path)
      end
      return cb(nil, 'File write finished ' .. path)
    end)
  end)
end

return M
