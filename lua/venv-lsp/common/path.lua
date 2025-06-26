local uv = (vim.uv or vim.loop)
local _path_separator = package.config:sub(1, 1)

local M = {}

---@param ... string
---@return string
function M.join(...)
  local path = table.concat({ ... }, _path_separator)
  return path
end

---@param path string
---@return string
function M.normalize(path)
  local abs_path = vim.fn.fnamemodify(path, ':p')
  return vim.fs.normalize(abs_path)
end

function M.stat(path)
  return uv.fs_stat(path)
end

---@return boolean
function M.exists(path)
  local stat = M.stat(path)
  return not not (stat and stat.type)
end

---@param ext string
---@return boolean
function M.is_ext(path, ext)
  return path:sub(-#ext) == ext
end

---@return nil
function M.ensure_file_exists(path)
  if M.exists(path) then
    return
  end
  local dir = vim.fn.fnamemodify(path, ':h')
  M.ensure_dir_exists(dir)
  if vim.fn.filereadable(path) == 0 then
    local f = io.open(path, 'w')
    if f then
      f:close()
    end
  end
end

---@return nil
function M.ensure_dir_exists(path)
  if M.exists(path) then
    return
  end
  local dir_stat = M.stat(path)
  if not (dir_stat and dir_stat.type == 'directory') then
    vim.fn.mkdir(path, 'p')
  end
end

--- Remove a specific subpath from the right of the current path.
---@param subpath string
---@return string
function M.remove_suffix(path, subpath)
  local base = path
  if base:sub(-#subpath) == subpath then
    local new_path = base:sub(1, #base - #subpath)
    return M.normalize(new_path)
  end
  return path
end

---@param only_type string|nil
---@return table
function M.list(path, only_type)
  local entries = {}
  local stat = M.stat(path)
  if not stat or stat.type ~= 'directory' then
    return entries
  end
  local handle = uv.fs_scandir(path)
  if not handle then
    return entries
  end
  while true do
    local name, typ = uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if not only_type or only_type == typ then
      table.insert(entries, M.join(path, name))
    end
  end
  return entries
end

return M
