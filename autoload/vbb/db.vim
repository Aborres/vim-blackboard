
func! s:ResetDB() abort
  return  #{
          \ name: 'BlackBoardDB',
          \ last_update: 'never',
          \ boards: {}
        \ }
endfunc

let s:db = s:ResetDB()

func! s:HasDB() abort
  return filereadable(g:bb_db_path)
endfunc

func s:GetDate() abort
  return strftime("%Y/%m/%d-%H:%M:%S")
endfunc

func! s:CreateDB(path) abort

  let s:db = s:ResetDB()

  call vbb#utils#create_json(s:db, a:path)
  call vbb#utils#echo("vim-blackboard: DB Created")

endfunc

func! s:FindBoard(board) abort

  let l:boards = s:db.boards

  if (!has_key(l:boards, a:board))
    let l:boards[a:board] = #{ 
          \ line: 0,
          \ col: 0,
          \ last_updated: 'never'
        \ }
  endif

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
  let s:db.last_update = l:date

  call vbb#utils#create_json(s:db, g:bb_db_path)

endfunc

func! s:DBIllFormed() abort

  if (type(s:db) != type({}))
    return 1
  endif

  let l:vanilla = s:ResetDB()

  for l:key in keys(l:vanilla)
    if (!has_key(s:db, l:key))
      return 1
    endif
  endfor

  return 0
endfunc

func! vbb#db#read() abort

  if (!s:HasDB())
    call s:CreateDB(g:bb_db_path)
    return
  endif

  let s:file = join(readfile(g:bb_db_path), '')
  let s:db = json_decode(s:file)

  if (s:DBIllFormed())
    call s:CreateDB(g:bb_db_path)
  endif

endfunc
