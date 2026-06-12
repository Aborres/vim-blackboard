
func! vbb#utils#check_create_directory(path) abort
  if (!isdirectory(a:path))
    call mkdir(a:path)
  endif
endfunc

func! vbb#utils#check_create_file(path) abort
  if (!filereadable(a:path))
    call writefile([], a:path)
    echo('Created board: ' . a:path)
  endif
endfunc

func vbb#utils#normalize_path(path) abort
  return fnameescape(expand(a:path))
endfunc

func! vbb#utils#get_board_path(path, board) abort

  let l:board_name = a:board
  if (l:board_name == '')
    let l:board_name = fnamemodify(v:this_session . '.vim_board', ':t')
  endif

  if (l:board_name == '')
    let l:board_name = g:bb_default_board
  endif

  let l:board_name = expand(l:board_name)
  return vbb#utils#normalize_path(a:path . '/' . l:board_name)

endfunc

func! vbb#utils#find_file_buffer(path) abort
  let l:full = fnamemodify(a:path, ':p')
  return bufnr(l:full)
endfunc

func! vbb#utils#is_qflist_open() abort
  return getqflist({'winid': 0}).winid != 0
endfunc

func! vbb#utils#toggle_qflist() abort
  if empty(filter(getwininfo(), 'v:val.quickfix'))
      execute 'copen ' .. expand(g:quickfix_size)
  else
      cclose
  endif
endfunc

