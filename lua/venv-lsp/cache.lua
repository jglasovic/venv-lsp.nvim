local config = require('venv-lsp.config')
local logger = require('venv-lsp.logger')
local utils = require('venv-lsp.utils')
local uv = (vim.uv or vim.loop)

local M = {
  _venv_cache = vim.empty_dict(),
  _initial_read = false,
  _pending_write = false,
}

---@return table
M._normalize_cache_data = function(data)
  if type(data) ~= 'table' then
    return vim.empty_dict()
  end
  return data
end

---@return table|nil
M._validate_cache_data = function(data)
  if type(data) ~= 'table' then
    return nil
  end
  return data
end

---@return nil
M._ensure_path_exists = function(path)
  local dir = vim.fn.fnamemodify(path, ':h')
  local dir_stat = uv.fs_stat(dir)
  if not (dir_stat and dir_stat.type == 'directory') then
    vim.fn.mkdir(dir, 'p')
  end
  if vim.fn.filereadable(path) == 0 then
    local f = io.open(path, 'w')
    if f then
      f:close()
    end
  end
end

-- reading the file is not async
---@return table|nil
M._read_cache_from_file = function(json_path)
  local f = io.open(json_path, 'r')
  if not f then
    logger.log('Cannot open file :' .. json_path, vim.log.levels.ERROR)
    return nil
  end
  local content = f:read('*a')
  f:close()
  local ok, data = pcall(vim.json.decode, content, { luanil = { object = true, array = true } })
  if not ok then
    return nil
  end
  return data
end

---@return nil
M._write_cache_to_file_debounced = function()
  if M._pending_write then
    return
  end
  M._pending_write = true
  vim.defer_fn(function()
    local config_dict = config.get()
    M._write_cache_to_file_async(config_dict.cache_json_path, M._venv_cache, function(err_msg, _)
      M._pending_write = false
      if err_msg then
        logger.log(err_msg, vim.log.levels.ERROR)
      end
      -- print success_msg
      -- if _ then
      --   logger.log(_, vim.log.levels.INFO)
      -- end
    end)
  end, 500)
end

-- writing to file is async
---@return nil
M._write_cache_to_file_async = function(json_path, data, cb)
  data = M._validate_cache_data(data)
  if not data then
    return cb('Data is not valid!')
  end
  local encoded = vim.json.encode(data)
  uv.fs_open(json_path, 'w', 420, function(err_open, fd)
    if err_open or not fd then
      return cb('Cannot open file for writing :' .. json_path)
    end
    uv.fs_write(fd, encoded, -1, function(err_write)
      uv.fs_close(fd)
      if err_write then
        return cb('Error writing cache file ' .. json_path)
      end
      return cb(nil, 'Cache file updated ' .. json_path)
    end)
  end)
end

---@return table
M._get_cache = function()
  if M._initial_read then
    return M._venv_cache
  end
  local config_dict = config.get()
  M._ensure_path_exists(config_dict.cache_json_path)
  local data = M._read_cache_from_file(config_dict.cache_json_path)
  if data then
    M._venv_cache = M._normalize_cache_data(data)
  end
  M._initial_read = true
  return M._venv_cache
end

M.get_root_dir_by_fname = function(fname)
  local buf_dir = vim.fn.fnamemodify(fname, ':p:h')
  for dir_path, _ in pairs(M._get_cache()) do
    if buf_dir:sub(1, #dir_path) == dir_path then
      return dir_path
    end
  end
end

M.get_root_dir_by_bufnr = function(bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  return M.get_root_dir_by_fname(fname)
end

M.init = function()
  M._get_cache()
end

---@return string|nil
M.get_venv = function(root_dir)
  local cache = M._get_cache()
  return cache[root_dir]
end

---@return nil
M.set_venv = function(root_dir, venv_path)
  if venv_path then
    root_dir = utils.normalize_dir_path(root_dir)
    if not utils.path_exists(root_dir) then
      return
    end
    local venv_python_path = utils.path_join(venv_path, utils.python_path_suffix)
    if not utils.path_exists(venv_python_path) then
      return
    end
  end
  M._venv_cache[root_dir] = venv_path
  M._write_cache_to_file_debounced()
end

-- command functions
M.add_venv = function()
  local current_dir = vim.fn.expand('%:p:h')
  vim.ui.input({ prompt = 'From root_dir: ', default = current_dir }, function(root_dir)
    if not root_dir or root_dir == '' then
      return
    end
    vim.ui.input({ prompt = 'VENV path: ', default = vim.env.VIRTUAL_ENV }, function(venv_path)
      if not venv_path or venv_path == '' then
        return
      end
      M.set_venv(root_dir, venv_path)
    end)
  end)
end

M.remove_venv = function()
  local cache = M._get_cache()
  vim.ui.select(vim.tbl_keys(cache), {
    prompt = 'Remove: ',
    format_item = function(root_dir)
      return root_dir .. ' => ' .. cache[root_dir]
    end,
  }, function(root_dir)
    if not root_dir or root_dir == '' then
      return
    end
    M.set_venv(root_dir, nil)
  end)
end

return M
