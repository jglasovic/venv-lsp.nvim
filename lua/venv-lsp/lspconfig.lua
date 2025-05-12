local lspconfig = require 'lspconfig'
local venv = require 'venv-lsp.venv'
local utils = require 'venv-lsp.util'
local pyright = require 'venv-lsp.lspconfig.pyright'
local basedpyright = require 'venv-lsp.lspconfig.basedpyright'
local M = {}

M.update_config = {
  ['pyright'] = pyright.update_config,
  ['basedpyright'] = basedpyright.update_config
  -- TODO: add others
}

-- By default auto venv detection is active
M.disabled_auto_venv = false
vim.api.nvim_create_user_command(
  'VenvAutoDisable',
  function()
    M.disabled_auto_venv = true
    print('Auto VIRTUAL_ENV detection is disabled!')
  end,
  { nargs = 0 }
)

vim.api.nvim_create_user_command(
  'VenvAutoEnable',
  function()
    M.disabled_auto_venv = false
    print('Auto VIRTUAL_ENV detection is enabled!')
  end,
  { nargs = 0 }
)

function M.on_new_config(update_config)
  return function(new_config, root_dir)
    if M.disabled_auto_venv then
      return
    end
    -- deactivate before searching for the new venv
    local previous_venv
    if vim.env.VIRTUAL_ENV then
      previous_venv = vim.env.VIRTUAL_ENV
      venv.deactivate_virtualenv()
    end

    local virtualenv_path = venv.get_virtualenv_path(root_dir)
    if virtualenv_path then
      update_config(new_config, virtualenv_path)
      venv.activate_virtualenv(virtualenv_path)
      return
    end

    -- set previous venv if the new one cannot be found
    if previous_venv then
      update_config(new_config, previous_venv)
      venv.activate_virtualenv(previous_venv)
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
    callback = function()
      if M.disabled_auto_venv then
        return
      end
      venv.activate_buffer()
    end,
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

function M.vim_lsp_config_setup()
  for name, callback in pairs(M.update_config) do
    local existing_config = vim.lsp.config[name]
    if not existing_config then
      existing_config = {}
    end
    local original_before_init = existing_config.before_init or nil
    existing_config['before_init'] = function(params, config)
      if original_before_init then
        original_before_init(params, config)
      end
      M.on_new_config(callback)(config, params.rootPath)
    end
    vim.lsp.config(name, existing_config)
    M.autocmd_venv()
  end
end

function M.init()
  if utils.is_0_11_nvim_version_or_higher() then
    -- Logic for Neovim 0.11.0 or higher
    M.vim_lsp_config_setup()
  else
    -- Logic for older Neovim versions
    lspconfig.util.on_setup = lspconfig.util.add_hook_after(lspconfig.util.on_setup, M.on_setup)
  end
end

return M
