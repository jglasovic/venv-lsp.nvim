local lspconfig = require 'lspconfig'
local venv = require 'venv-lsp.venv'
local pyright = require 'venv-lsp.lspconfig.pyright'
local M = {}

M.update_config = {
  ['pyright'] = pyright.update_config
  -- TODO: add others
}

function M.on_new_config(update_config)
  return function(new_config, root_dir)
    venv.deactivate_virtualenv()
    local virtualenv_path = venv.get_virtualenv_path(root_dir)
    if virtualenv_path then
      update_config(new_config, virtualenv_path)
      venv.activate_virtualenv(virtualenv_path)
    end
  end
end

function M.autocmd_venv()
  if M.autocmd_set then
    return
  end
  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('VenvLsp', { clear = true }),
    pattern = { "*.py" },
    callback = venv.activate_buffer,
  })
  M.autocmd_set = true
end

function M.on_setup(config)
  local update_config = M.update_config[config.name]
  if update_config then
    config.on_new_config = lspconfig.util.add_hook_after(config.on_new_config, M.on_new_config(update_config))
    M.autocmd_venv()
  end
end

function M.init()
  lspconfig.util.on_setup = lspconfig.util.add_hook_after(lspconfig.util.on_setup, M.on_setup)
end

return M
