local config_utils = require('venv-lsp.config')
local uv = vim.loop
local config = config_utils.config
local fallback_cache_json_path = config_utils.fallback_cache_json_path

local M = {
  _cache = { root_dir_map = vim.empty_dict(), venv_map = vim.empty_dict() },
  _initial_read = false,
  _pending_write = false
}

M._validate_cache_data = function(data)
  if type(data) ~= "table" or type(data.root_dir_map) ~= "table" or type(data.venv_map) ~= "table" then
    return M._cache
  end
  return data
end

M._validate_cache_path = function(json_path)
  -- check if the path is with json ext
  if json_path:sub(-5) ~= ".json" then
    vim.notify("`cache_json_path` value is not a valid '.json' file :" .. json_path, vim.log.levels.ERROR)
    json_path = fallback_cache_json_path
    config.cache_json_path = json_path
    vim.notify("Using fallback path " .. json_path, vim.log.levels.WARN)
  end
  local dir = vim.fn.fnamemodify(json_path, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
  if vim.fn.filereadable(json_path) == 0 then
    local f = io.open(json_path, "w")
    if f then f:close() end
  end
end

-- reading the file is not async
-- want to ingest the data before any lsp starts, blocking function
M._read_cache_from_file = function(json_path)
  local f = io.open(json_path, "r")
  if not f then
    vim.notify("Cannot open file :" .. json_path, vim.log.levels.ERROR)
    vim.notify("Working with runtime cache", vim.log.levels.WARN)
    return M._cache
  end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content, { luanil = { object = true, array = true } })
  if not ok then
    return M._cache
  end
  M._cache = M._validate_cache_data(data)
  return M._cache
end

M._write_cache_to_file_debounced = function()
  if M._pending_write then return end
  M._pending_write = true
  vim.defer_fn(function()
    M._write_cache_to_file_async(config.cache_json_path, M._cache)
    M._pending_write = false
  end, 300)
end

-- writing to file is async
-- no need to wait for this action, nothing depends on it
M._write_cache_to_file_async = function(json_path, data)
  data = M._validate_cache_data(data)
  local encoded = vim.json.encode(data)
  uv.fs_open(json_path, "w", 420, function(err_open, fd)
    if err_open or not fd then
      vim.schedule(function()
        vim.notify("Cannot open file for writing: " .. json_path, vim.log.levels.ERROR)
      end)
      return
    end
    uv.fs_write(fd, encoded, -1, function(err_write)
      uv.fs_close(fd)
      if err_write then
        vim.schedule(function()
          vim.notify("Error writing cache file: " .. json_path, vim.log.levels.ERROR)
        end)
        -- else
        -- vim.schedule(function()
        --   vim.notify("Cache file updated", vim.log.levels.DEBUG)
        -- end)
      end
    end)
  end)
end

M.init = function()
  if M._initial_read then
    return
  end
  M._validate_cache_path(config.cache_json_path)
  M._read_cache_from_file(config.cache_json_path)
  M._initial_read = true
end

M._get_cache = function()
  if M._initial_read then
    return M._cache
  end
  return M._read_cache_from_file()
end

M.get_root_dir_map = function()
  local cache = M._get_cache()
  return cache.root_dir_map
end

M.get_venv_map = function()
  local cache = M._get_cache()
  return cache.venv_map
end

M.get_root_dir = function(root_dir)
  local root_dir_map = M.get_root_dir_map()
  return vim.tbl_get(root_dir_map, root_dir)
end

M.set_root_dir = function(from_root_dir, to_root_dir)
  M._cache.root_dir_map[from_root_dir] = to_root_dir
  M._write_cache_to_file_debounced()
end

M.get_venv = function(root_dir)
  local venv_map = M.get_venv_map()
  return vim.tbl_get(venv_map, root_dir)
end

M.set_venv = function(root_dir, venv_path)
  M._cache.venv_map[root_dir] = venv_path
  M._write_cache_to_file_debounced()
end

M.add_root_dir = function()
  local current_dir = vim.fn.expand('%:p:h')
  vim.ui.input(
    { prompt = "From root_dir: ", default = current_dir },
    function(from_root_dir)
      if not from_root_dir or from_root_dir == "" then
        return
      end
      vim.ui.input(
        { prompt = "To root_dir: ", default = current_dir },
        function(to_root_dir)
          if not to_root_dir or to_root_dir == "" then
            return
          end
          M.set_root_dir(from_root_dir, to_root_dir)
        end
      )
    end
  )
end

M.remove_root_dir = function()
  vim.ui.select(
    vim.tbl_keys(M.get_root_dir_map()),
    { prompt = "Remove :" },
    function(root_dir)
      if not root_dir or root_dir == "" then
        return
      end
      M.set_root_dir(root_dir, nil)
    end
  )
end

M.add_venv = function()
  local current_dir = vim.fn.expand('%:p:h')
  vim.ui.input(
    { prompt = "From root_dir: ", default = current_dir },
    function(root_dir)
      if not root_dir or root_dir == "" then
        return
      end
      vim.ui.input(
        { prompt = "VENV path: ", default = vim.env.VIRTUAL_ENV },
        function(venv_path)
          if not venv_path or venv_path == "" then
            return
          end
          M.set_venv(root_dir, venv_path)
        end
      )
    end
  )
end

M.remove_venv = function()
  vim.ui.select(
    vim.tbl_keys(M.get_venv_map()),
    { prompt = "Remove " },
    function(root_dir)
      if not root_dir or root_dir == "" then
        return
      end
      M.set_venv(root_dir, nil)
    end
  )
end

return M
