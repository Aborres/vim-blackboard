
let g:bb_default_board = 'default'
let g:bb_root = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/..'
let g:bb_boards_path = g:bb_root . '/boards'

let g:bb_enable_wrap = 1

" Constants
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

" Allows to open or create a board by name
func! BB_Open(board = '', focus = 0) abort
  call vbb#plugin#blackboard_open(a:board, a:focus)
endfunc

" Allows to close a board by name
func! BB_Close(board = '') abort
  call vbb#plugin#blackboard_close(a:board, a:focus)
endfunc

" Allows to open/close a board by name
func! BB_BlackBoard(board = '', focus = 0) abort
  call vbb#plugin#blackboard(a:board, a:focus)
endfunc

func! BB_IsOpen(board) abort
  return vbb#plugin#is_blackboard_open(a:board)
endfunc

" Allows to close a particular file from a BlackBoard
func! BB_OpenFile(file, focus = 0) abort
  call vbb#plugin#open_file(a:file, a:focus)
endfunc

func! BB_CloseFile(file) abort
  return vbb#plugin#close_file(a:file)
endfunc

" Allows to open/close a particular file into a BlackBoard
func! BB_File(file, focus = 0) abort
  call vbb#plugin#file(a:file, a:focus)
endfunc

func! BB_IsFileOpen(file) abort
  return vbb#plugin#is_file_open(a:file)
endfunc

augroup VimBBEvents
  autocmd!
  autocmd VimEnter    * call vbb#plugin#start()
  autocmd VimLeavePre * call vbb#plugin#end()
augroup END

