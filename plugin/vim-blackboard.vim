
let g:bb_default_board = 'default'
let g:bb_root = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/..'
let g:bb_boards_path = g:bb_root . '/boards'

let g:bb_board_left  = 0
let g:bb_board_right = 1
let g:bb_board_up    = 2
let g:bb_board_down  = 3

let g:bb_board_location = g:bb_board_left

func! BB_New() abort
  call vbb#plugin#blackboard_new(a:board, a:focus)
endfunc

func! BB_Delete() abort
  call vbb#plugin#blackboard_delete(a:board, a:focus)
endfunc

func! BB_Open(board = '', focus = 0) abort
  call vbb#plugin#blackboard_open(a:board, a:focus)
endfunc

func! BB_Close(board = '') abort
  call vbb#plugin#blackboard_close(a:board, a:focus)
endfunc

func! BB_BlackBoard(board = '', focus = 0) abort
  call vbb#plugin#blackboard(a:board, a:focus)
endfunc
