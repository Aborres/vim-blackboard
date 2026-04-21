
let s:bb_initialized = 0

func! s:CheckCreateDirectory(path) abort
  if (!isdirectory(a:path))
    call mkdir(a:path)
  endif
endfunc

func! s:CheckCreateFile(path) abort
  if (!filereadable(a:path))
    call writefile([], a:path)
    echo('Created board: ' . a:path)
  endif
endfunc

func s:NormalizePath(path) abort
  return fnameescape(expand(a:path))
endfunc

func! s:GetBoardPath(path, board) abort

  let l:board_name = a:board
  if (l:board_name == '')
    let l:board_name = fnamemodify(v:this_session . '.vim_board', ':t')
  endif

  if (l:board_name == '')
    let l:board_name = g:bb_default_board
  endif

  let l:board_name = expand(l:board_name)
  return s:NormalizePath(a:path . '/' . l:board_name)

endfunc

func! s:FindBoard(board) abort

  let l:board_path = s:NormalizePath(g:bb_boards_path)
  let l:board_path = s:GetBoardPath(l:board_path, a:board)

  let l:full = fnamemodify(l:board_path, ':p')
  return bufnr(l:full)
endfunc

func! s:IsBoardLoaded(board) abort
  let l:bnr = s:FindBoard(a:board)
  if (l:bnr > 0)
    return !empty(win_findbuf(l:bnr))
  endif

  return 0
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

func! vbb#plugin#blackboard_new(board) abort

  let l:board_path = s:NormalizePath(g:bb_boards_path)
  call s:CheckCreateDirectory(l:board_path)

  let l:board_path = s:GetBoardPath(l:board_path, a:board)
  call s:CheckCreateFile(l:board_path)

  return l:board_path
endfunc

func! vbb#plugin#blackboard_delete() abort
endfunc

func! s:IsQuickFixOpen() abort
  return getqflist({'winid': 0}).winid != 0
endfunc

func! s:ToggleQuickFix() abort
  if empty(filter(getwininfo(), 'v:val.quickfix'))
      execute 'copen ' .. expand(g:quickfix_size)
  else
      cclose
  endif
endfunc

func! vbb#plugin#blackboard_open(board = '', focus = 0) abort

  if (s:IsBoardLoaded(a:board))
    return
  endif
  
  let l:board_path = vbb#plugin#blackboard_new(a:board)
  
  if (!filereadable(l:board_path))
    echo "Couldn't find board: " . l:board_path
    return
  endif

  let l:win = win_getid()

  let l:qf = s:IsQuickFixOpen()
  if (l:qf)
    call s:ToggleQuickFix()
  endif

  execute 'vsplit ' . l:board_path
  if (g:bb_enable_wrap)
    setlocal wrap
  endif

  call s:MoveBoard(g:bb_board_location)

  if (l:qf)
    call s:ToggleQuickFix()
  endif

  if (!a:focus)
    call win_gotoid(l:win)
  endif

endfunc

func! vbb#plugin#blackboard_close(board = '') abort

  let l:bnr  = s:FindBoard(a:board)
  if (l:bnr <= 0)
    echo('Failed to find buffer for board: ' . a:board)
    return
  endif

  let l:curwin = win_getid()
  let l:curbuf = winbufnr(l:curwin)

  if getbufvar(l:bnr, '&modified')
    let l:win = win_findbuf(l:bnr)[0]
    call win_execute(l:win, 'update', 'silent!')
  endif

  execute 'bwipeout ' . l:bnr

  let l:new_win = win_findbuf(l:curbuf)
  if (!empty(l:new_win))
    call win_gotoid(l:new_win[0])
  endif

endfunc

func! vbb#plugin#blackboard(board = '', focus = 0) abort
  if (!s:IsBoardLoaded(a:board))
    call vbb#plugin#blackboard_open(a:board, a:focus)
  else
    call vbb#plugin#blackboard_close(a:board)
  endif
endfunc
