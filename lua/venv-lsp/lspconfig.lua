local lspconfig = require 'lspconfig'
local pyright = require 'venv-lsp.lspconfig.pyright'
local venv = require 'venv-lsp.venv'
local M = {}

M.lsp = {
  ['pyright'] = pyright.on_new_config
  -- TODO: add others
}

-- on_attach for new buffer, save buffer's activated venv
function M.on_attach(_, _)
  if vim.env.VIRTUAL_ENV then
    vim.b.VIRTUAL_ENV = vim.env.VIRTUAL_ENV
  end
end

function M.autocmd_venv()
  local group = vim.api.nvim_create_augroup('VenvLsp', { clear = true })
  -- on BufEnter activate virtual env if exists and not activated yet
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    pattern = { "*.py" },
    callback = function(_)
      local buf_venv = vim.b.VIRTUAL_ENV
      if buf_venv and buf_venv ~= vim.env.VIRTUAL_ENV then
        venv.deactivate_virtualenv()
        venv.activate_virtualenv(buf_venv)
      end
    end,
  })
end

function M.on_setup(config)
  local on_new_config = M.lsp[config.name]
  if on_new_config then
    config.on_new_config = lspconfig.util.add_hook_after(config.on_new_config, on_new_config)
    config.on_attach = lspconfig.util.add_hook_after(config.on_attach, M.on_attach)
    M.autocmd_venv()
  end
end

function M.init()
  lspconfig.util.on_setup = lspconfig.util.add_hook_after(lspconfig.util.on_setup, M.on_setup)
end

return M
