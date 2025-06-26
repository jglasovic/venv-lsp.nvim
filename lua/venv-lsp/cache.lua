local fs = require('venv-lsp.common.fs')
local path = require('venv-lsp.common.path')
local logger = require('venv-lsp.common.logger')
local config = require('venv-lsp.config').get()

local M = {
  _mem_cache = vim.empty_dict(),
  _venv_cache = vim.empty_dict(),
  _initial_read = false,
  _pending_write = false,
}

---Validate cache data, returning nil if not a table.
---@param data table
---@return table|nil
M._validate_cache_data = function(data)
  if type(data) ~= 'table' then
    return nil
  end
  return data
end

-- reading the file is not async
---Read cache from a JSON file.
---@param json_path string
---@return table|nil
M._read_cache_from_file = function(json_path)
  local content, err = fs.read_file(json_path)
  if err then
    logger.error(err)
    return nil
  end
  local ok, data = pcall(vim.json.decode, content, { luanil = { object = true, array = true } })
  if not ok then
    return nil
  end
  return data
end

---Write cache to file with debounce (async).
---@return nil
M._write_cache_to_file_debounced = function()
  if M._pending_write then
    return
  end
  M._pending_write = true
  vim.defer_fn(function()
    M._write_cache_to_file_async(config.cache_json_path, M._venv_cache, function(err_msg, _)
      M._pending_write = false
      if err_msg then
        logger.error(err_msg)
      end
      -- print success_msg
      -- if _ then
      --   logger.info(_)
      -- end
    end)
  end, 500)
end

-- writing to file is async
---Write cache to file asynchronously.
---@param json_path string
---@param data table
---@param cb fun(err_msg: string|nil, success_msg: string|nil): nil
---@return nil
M._write_cache_to_file_async = function(json_path, data, cb)
  local validated_data = M._validate_cache_data(data)
  if not validated_data then
    return cb('Data is not valid!')
  end
  local encoded = vim.json.encode(validated_data)
  fs.write_file_async(json_path, encoded, cb)
end

---Get the venv cache, reading from file if needed.
---@return table<string, string|nil>
M.get_venv_cache = function()
  if M._initial_read then
    return M._venv_cache
  end
  if not config.disable_cache then
    local data = M._read_cache_from_file(config.cache_json_path)
    if data then
      M._venv_cache = data
    end
  end
  M._initial_read = true
  return M._venv_cache
end

---Get the root directory from a filename by matching against the venv cache.
---@param fname string
---@return string|nil
M.get_root_dir_by_fname = function(fname)
  local buf_dir = vim.fn.fnamemodify(fname, ':p:h')
  for dir_path, _ in pairs(M.get_venv_cache()) do
    if buf_dir:sub(1, #dir_path) == dir_path then
      return dir_path
    end
  end
end

---Get the root directory from a buffer number.
---@param bufnr integer
---@return string|nil
M.get_root_dir_by_bufnr = function(bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  return M.get_root_dir_by_fname(fname)
end

---Initialize the cache by reading from file.
---@return nil
M.init = function()
  path.ensure_file_exists(config.cache_json_path)
  M.get_venv_cache()
end

---Get the virtualenv path for a given root directory.
---@param root_dir string
---@return string|nil
M.get_venv = function(root_dir)
  local cache = M.get_venv_cache()
  return cache[root_dir]
end

---Set the virtualenv path for a given root directory.
---@param root_dir string
---@param virtualenv_path string|nil
---@return nil
M.set_venv = function(root_dir, virtualenv_path)
  M._venv_cache[root_dir] = virtualenv_path
  if config.disable_cache then
    return
  end
  M._write_cache_to_file_debounced()
end

---In-memory cache wrapper for a function.
---@generic R
---@param cb fun(input_key: string): R
---@param cache_key string
---@return fun(input_key: string):R
M.with_memcache = function(cb, cache_key)
  if not M._mem_cache[cache_key] then
    M._mem_cache[cache_key] = {}
  end

  return function(input_key)
    if not M._mem_cache[cache_key][input_key] then
      local result = cb(input_key)
      if not result then
        return nil
      end
      M._mem_cache[cache_key][input_key] = result
    end
    return M._mem_cache[cache_key][input_key]
  end
end

return M
