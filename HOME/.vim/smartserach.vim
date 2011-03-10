fun! CharsToPattern(list)
  let pattern = ''
  let spaces='\%(\n\|\s\)\+' " newline or space at least once
  for i in a:list
    let pattern .= '\<'.i.'\S*'.spaces
  endfor
  return pattern
endfun

" starts an event loop polling for keyboard input
" type esc to abort, <cr> to accept smart search
" TODO: don't use cursorline but use regex to highlight match
fun! SmartSearch()
  echo "smart-search, type some chars"
  " FIXME: turn it off again conditionally
  set cursorline
  let oldpos = getpos('.')
  let typedchars = [] " keeps a list of characters

  while 1
    let c = getchar()

    if index([13,10],c) >= 0
      " pressed enter, keeep position
      call feedkeys("/".CharsToPattern(typedchars)."\n")
      return
    elseif index([27], c) >=0
      " esc, abort
      call setpos('.', oldpos)
      return ""

    elseif c == "\<bs>"
      " backspace, remove last item
      let typedchars = typedchars[:-2]
    else
      call add(typedchars, nr2char(c))
    endif

    " reset cursor pos cause we want the next match
    call setpos('.', oldpos)
    let g:pattern = CharsToPattern(typedchars)
    call search(g:pattern, 'w')
    redraw!
    echo join(typedchars,'').' press esc to exit, <cr> to accept'
  endwhile
endf

noremap <F2> :call SmartSearch()<cr>
