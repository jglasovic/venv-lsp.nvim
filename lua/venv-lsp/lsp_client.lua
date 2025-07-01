local language_servers = require('venv-lsp.language_servers')
local path = require('venv-lsp.common.path')
local get_clients = vim.lsp.get_clients -- TODO: test if for older nvim versions
local api = vim.api

local ls_names = vim.tbl_keys(language_servers)

---@param dir string
---@return integer[]
local get_buffers = function(dir)
  local buffers = api.nvim_list_bufs()
  return vim.tbl_filter(function(bufnr)
    local bufname = api.nvim_buf_get_name(bufnr)
    return path.compare(dir, bufname)
  end, buffers)
end

local M = {}

function M.restart_for_root_dir(root_dir)
  -- Find all buffers under root_dir
  local buffers = get_buffers(root_dir)
  -- Detach from all known LSP clients
  for _, bufnr in ipairs(buffers) do
    local clients = get_clients({ bufnr = bufnr })
    for _, client in ipairs(clients) do
      if vim.tbl_contains(ls_names, client.name) then
        -- delete buffer's venv cache
        vim.b[bufnr].VIRTUAL_ENV = nil
        -- detach buffer from the client
        vim.lsp.buf_detach_client(bufnr, client.id)
        -- if there are 0 attached buffers, stop client
        if next(client.attached_buffers) == nil then
          client:stop(true)
        end
      end
    end
  end

  -- easiest way to restart them is to exec 'edit' cmd
  for _, bufnr in ipairs(buffers) do
    api.nvim_buf_call(bufnr, function()
      vim.cmd('edit')
    end)
  end
end

return M
