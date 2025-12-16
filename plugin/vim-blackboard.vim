
let s:bb_initialized = 0
let s:bb_root = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/..'

let g:bb_default_board = 'default'
let g:bb_boards_path = s:bb_root . '/boards'

let g:bb_board_left  = 0
let g:bb_board_right = 1
let g:bb_board_up    = 2
let g:bb_board_down  = 3

let g:bb_board_location = g:bb_board_left

func! BB_Delete() abort
endfunc

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
  return s:FindBoard(a:board) > 0
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

func! BB_New(board) abort

  let l:board_path = s:NormalizePath(g:bb_boards_path)
  call s:CheckCreateDirectory(l:board_path)

  let l:board_path = s:GetBoardPath(l:board_path, a:board)
  call s:CheckCreateFile(l:board_path)

  return l:board_path
endfunc

func! BB_Open(board = '', focus = 0) abort

  if (s:IsBoardLoaded(a:board))
    return
  endif
  
  let l:board_path = BB_New(a:board)
  
  if (!filereadable(l:board_path))
    echo "Couldn't find board: " . l:board_path
    return
  endif

  let l:win = win_getid()

  execute 'vsplit ' . l:board_path
  call s:MoveBoard(g:bb_board_location)

  if (!a:focus)
    call win_gotoid(l:win)
  endif

endfunc

func! BB_Close(board = '') abort

  let l:bnr  = s:FindBoard(a:board)
  if (l:bnr <= 0)
    echo('Failed to find buffer for board: ' . a:board)
    return
  endif

  execute 'bwipeout ' . l:bnr

endfunc

func! BB_BlackBoard(board = '', focus = 0) abort
  if (!s:IsBoardLoaded(a:board))
    call BB_Open(a:board, a:focus)
  else
    call BB_Close(a:board)
  endif
endfunc
