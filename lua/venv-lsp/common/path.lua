local uv = (vim.uv or vim.loop)
local _path_separator = package.config:sub(1, 1)

---@class Path
---@field _path string
---@field _stat uv.fs_stat.result|nil
---@field _normalized boolean|nil
Path = {}
Path.__index = Path

---@param ... string
---@return Path
function Path:new(...)
  local path = table.concat({ ... }, _path_separator)
  local obj = setmetatable({ _path = path }, Path)
  self.__index = self
  return obj
end

---@return string
function Path:get()
  return self._path
end

---@return nil
function Path:normalize()
  if not self._normalized then
    local abs_path = vim.fn.fnamemodify(self._path, ':p')
    self._path = vim.fs.normalize(abs_path)
    self._normalized = true
  end
end

---@return uv.fs_stat.result|nil
function Path:stat()
  if self._stat then
    return self._stat
  end
  self._stat = uv.fs_stat(self._path)
  return self._stat
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

--- append to the current path one or more strings
---@param ... string
---@return Path
function Path:append(...)
  return Path:new(self._path, ...)
end

--- Remove a specific subpath from the right of the current path.
---@param subpath string
---@return Path
function Path:remove_suffix(subpath)
  local base = self._path
  if base:sub(-#subpath) == subpath then
    local new_path = base:sub(1, #base - #subpath)
    local path = Path:new(new_path)
    path:normalize()
    return path
  end
  return Path:new(self._path)
end

---@param only_type string|nil
---@return table
function Path:list(only_type)
  local entries = {}
  local stat = self:stat()
  if not stat or stat.type ~= 'directory' then
    return entries
  end
  local handle = uv.fs_scandir(self._path)
  if not handle then
    return entries
  end
  while true do
    local name, typ = uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if not only_type or only_type == typ then
      table.insert(entries, self:append(name):get())
    end
  end
  return entries
end

---@param ... string
---@return Path
M = function(...)
  return Path:new(...)
end

return M
