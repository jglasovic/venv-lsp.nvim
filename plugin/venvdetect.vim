function venvdetect#install()
  if executable('venvdetect')
    return
  endif

  let raw_script_url = "https://raw.githubusercontent.com/jglasovic/venvdetect/refs/heads/main/install"

  let cmd = ""
  if executable('curl')
    let cmd = 'curl -fsSL ' . shellescape(raw_script_url) . ' | bash'
  elseif executable('wget')
    let cmd = 'wget -qO- ' . shellescape(raw_script_url) . ' | bash'
  else
    throw "Cannot install venvdetect!"
  endif

  call system(cmd)
  if v:shell_error != 0
    echom "Script execution failed: " . result
  endif

endfunction
