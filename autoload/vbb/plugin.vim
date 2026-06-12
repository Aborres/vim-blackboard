
let s:bb_initialized = 0
let s:bb_open = 0
let s:bb_file = ''

func! vbb#plugin#is_file_open(board) abort

  let l:bnr = vbb#utils#find_file_buffer(a:board)
  if (l:bnr > 0)
    return !empty(win_findbuf(l:bnr))
  endif

  return 0
endfunc

func! s:FindBoardBuffer(board) abort
  let l:board_path = vbb#utils#normalize_path(g:bb_boards_path)
  let l:board_path = vbb#utils#get_board_path(l:board_path, a:board)
  return vbb#utils#find_file_buffer(l:board_path)
endfunc

func! vbb#plugin#is_blackboard_open(board) abort

  let l:bnr = s:FindBoardBuffer(a:board)
  if (l:bnr > 0)
    return !empty(win_findbuf(l:bnr))
  endif

  return 0
endfunc

func! vbb#plugin#blackboard_get(board) abort

  let l:board_path = vbb#utils#normalize_path(g:bb_boards_path)
  call vbb#utils#check_create_directory(l:board_path)

  let l:board_path = vbb#utils#get_board_path(l:board_path, a:board)
  call vbb#utils#check_create_file(l:board_path)

  return simplify(l:board_path)
endfunc

func! vbb#plugin#blackboard_delete() abort
endfunc

func! vbb#plugin#blackboard_open(board = '', focus = 0) abort

  if (vbb#plugin#is_blackboard_open(a:board))
    return 0
  endif
  
  let l:board_path = vbb#plugin#blackboard_get(a:board)
  return vbb#plugin#open_file(l:board_path, a:focus)
endfunc

func! vbb#plugin#blackboard_close(board = '') abort

  if (!vbb#plugin#is_blackboard_open(a:board))
    return 0
  endif

  let l:board_path = vbb#plugin#blackboard_get(a:board)
  return vbb#plugin#close_file(l:board_path)
endfunc

func! vbb#plugin#blackboard(board = '', focus = 0) abort
  if (!vbb#plugin#is_blackboard_open(a:board))
    return vbb#plugin#blackboard_open(a:board, a:focus)
  else
    return vbb#plugin#blackboard_close(a:board)
  endif
endfunc

func! s:MoveBoard(dir) abort
  if (a:dir == g:bb_board_left)
    wincmd H
  elseif (a:dir == g:bb_board_right)
    wincmd L
  elseif (a:dir == g:bb_board_up)
    wincmd J
  elseif (a:dir == g:bb_board_down)
    wincmd K
  endif
endfunc

func! s:MoveCursor(line, col) abort

  let l:buff = bufnr('%')
  call setpos('.', [l:buff, a:line, a:col, 0])

endfunc

func! s:HandleBufferSwitch() abort

  let l:left = expand('<afile>')
  if (l:left == s:bb_file)
    let l:line = line('.')
    let l:col  = col('.')
    let l:board = vbb#plugin#blackboard_get('')
    call vbb#db#write_board(l:board, l:line, l:col)
  endif

endfunc

func! s:RegisterEvent() abort
  augroup BBOnBuffLeave
    autocmd!
    if s:bb_open
      autocmd BufLeave * call s:HandleBufferSwitch() 
    endif
  augroup END
endfunc

func! vbb#plugin#open_file(board, focus) abort

  if (!filereadable(a:board))
    call vbb#utils#echo("Couldn't find file: " . a:board)
    return 0
  endif

  let l:win = win_getid()

  let l:qf = vbb#utils#is_qflist_open()
  if (l:qf)
    call vbb#utils#toggle_qflist()
  endif

  " Cache position in case we don't want to focus
  let l:buff = bufnr('%')
  let l:line = line('.')
  let l:col  = col('.')

  execute 'vsplit ' . a:board
  if (g:bb_enable_wrap)
    setlocal wrap
    setlocal expandtab
    setlocal tabstop=2
    setlocal shiftwidth=2
    setlocal softtabstop=2
  endif

  call s:MoveBoard(g:bb_board_location)

  if (l:qf)
    call vbb#utils#toggle_qflist()
  endif

  if (a:focus)
    let l:board_config = vbb#db#read_board(a:board)
    call s:MoveCursor(l:board_config.line, l:board_config.col)
  else
    call win_gotoid(l:win)
  endif

  let s:bb_open = 1
  let s:bb_file = a:board
  call s:RegisterEvent()

  return 1
endfunc

func! vbb#plugin#close_file(board) abort

  let l:bnr  = vbb#utils#find_file_buffer(a:board)
  if (l:bnr <= 0)
    call vbb#utils#echo('Failed to find buffer for board: ' . a:board)
    return 0
  endif

  let l:curwin = win_getid()
  let l:curbuf = winbufnr(l:curwin)

  " Cache position if buff had focus
  if (bufnr('%') == l:bnr)
    let l:line = line('.')
    let l:col  = col('.')
    call vbb#db#write_board(a:board, l:line, l:col)
  endif

  if getbufvar(l:bnr, '&modified')
    let l:win = win_findbuf(l:bnr)[0]
    call win_execute(l:win, 'update', 'silent!')
  endif

  execute 'bwipeout ' . l:bnr

  let l:new_win = win_findbuf(l:curbuf)
  if (!empty(l:new_win))
    call win_gotoid(l:new_win[0])
  endif

  let s:bb_open = 0
  let s:bb_file = ''
  call s:RegisterEvent()

  return 1

endfunc

func! vbb#plugin#file(file, focus) abort
  if (!vbb#plugin#is_file_open(a:file))
    return vbb#plugin#open_file(a:file, a:focus)
  else
    return vbb#plugin#close_file(a:file)
  endif
endfunc

func! vbb#plugin#start() abort
  call vbb#db#read()
endfunc

func! vbb#plugin#end() abort
  call vbb#db#write()
endfunc
