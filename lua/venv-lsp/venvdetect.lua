local shell = require('venv-lsp.common.shell')

local M = {}
function M.auto_detect_virtualenv(root_dir)
  local cmd = 'venvdetect ' .. root_dir
  local venv, code = shell.exec_str(cmd)
  if code ~= 0 then
    return nil
  end
  return venv
end

return M
