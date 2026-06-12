
let s:db_path = g:bb_boards_path . '/bb_db.json'
let s:db = {}

func! s:HasDB() abort
  return filereadable(s:db_path)
endfunc

func s:GetDate() abort
  return strftime("%Y/%m/%d-%H:%M:%S")
endfunc

func! s:CreateDB(path) abort

  let l:db = {
          \ 'name': 'BlackBoardDB',
          \ 'last_update': 'never',
          \ 'boards': {}
        \ }

  let l:out = json_encode(l:db)
  call writefile([l:out], a:path)

  echo("vim-blackboard: DB Created")

endfunc

func! s:FindBoard(board) abort

  let l:boards = s:db.boards

  if (!len(l:boards))
    let l:boards = {}
  endif

  if (!has_key(l:boards, a:board))
    let l:boards[a:board] = {'line': 0, 'col': 0, 'last_updated': 'never'}
  endif

  let s:db.boards = l:boards

  return l:boards[a:board]

endfunc

func! vbb#db#write_board(board, line, col) abort

  let l:board = s:FindBoard(a:board)

  let l:board.line         = a:line
  let l:board.col          = a:col
  let l:board.last_updated = s:GetDate()

  let s:db.boards[a:board] = l:board

endfunc

func! vbb#db#read_board(board) abort

  let l:board = s:FindBoard(a:board)

  let l:line = l:board.line
  let l:col  = l:board.col

  return { 'line': l:line, 'col': l:col }
endfunc

func! vbb#db#write() abort

  let l:date = s:GetDate()
  let s:db['last_update'] = string(l:date)

  let l:out = json_encode(s:db)
  call writefile([l:out], s:db_path)

endfunc

func! vbb#db#read() abort

  if (!s:HasDB())
    call s:CreateDB(s:db_path)
  endif

  let s:file = join(readfile(s:db_path), '')
  let s:db = json_decode(s:file)

endfunc
