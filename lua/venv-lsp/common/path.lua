local uv = (vim.uv or vim.loop)
local _path_separator = package.config:sub(1, 1)

---@class Path
---@field _path string
---@field _stat uv.fs_stat.result|nil
Path = {}
Path.__index = Path

---@param ... string
---@return Path
function Path:new(...)
  local path = table.concat({ ... }, _path_separator)
  local abs_path = vim.fn.fnamemodify(path, ':p')
  local normalized = vim.fs.normalize(abs_path)
  local obj = setmetatable({ _path = normalized }, Path)
  self.__index = self
  return obj
end

---@return string
function Path:get()
  return self._path
end

---@return uv.fs_stat.result|nil
function Path:stat()
  if self._stat then
    return self._stat
  end
  local stat = uv.fs_stat(self._path)
  return stat
end

---@return boolean
function Path:exists()
  local stat = self:stat()
  return stat and stat.type and true or false
end

---@param ext string
---@return boolean
function Path:is_ext(ext)
  return self._path:sub(-#ext) == ext
end

---@return nil
function Path:ensure_file_exists()
  if self:exists() then
    return
  end
  local dir = Path:new(vim.fn.fnamemodify(self._path, ':h'))
  dir:ensure_dir_exists()
  if vim.fn.filereadable(self._path) == 0 then
    local f = io.open(self._path, 'w')
    if f then
      f:close()
    end
  end
end

---@return nil
function Path:ensure_dir_exists()
  if self:exists() then
    return
  end
  local dir_stat = self:stat()
  if not (dir_stat and dir_stat.type == 'directory') then
    vim.fn.mkdir(self._path, 'p')
  end
end

--- Join the current path with one or more strings or Path objects.
---@param ... string|Path
---@return Path
function Path:join(...)
  local segments = { self:get() }
  for _, p in ipairs({ ... }) do
    table.insert(segments, type(p) == 'table' and p._path or p)
  end
  return Path:new(table.unpack(segments))
end

--- Remove a specific subpath from the right of the current path.
---@param subpath string|Path
---@return Path
function Path:remove_suffix(subpath)
  local base = self:get()
  local suffix = subpath
  if type(subpath) == 'table' then
    suffix = subpath:get()
  end
  local sep = _path_separator
  if base:sub(-#sep - #suffix) == sep .. suffix then
    local new_path = base:sub(1, #base - #sep - #suffix)
    if new_path == '' then
      new_path = sep
    end
    return Path:new(new_path)
  end
  return Path:new(self._path)
end

---@return table
function Path:list()
  local entries = {}
  local stat = self:stat()
  if stat and stat.type ~= 'directory' then
    return entries
  end
  local handle = uv.fs_scandir(self._path)
  if not handle then
    return entries
  end
  while true do
    local path = uv.fs_scandir_next(handle)
    if not path then
      break
    end
    table.insert(entries, path)
  end
  return entries
end

return Path
