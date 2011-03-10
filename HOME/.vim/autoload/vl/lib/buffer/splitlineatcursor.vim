" script-purpose: get the current line and returns an array containg the text till and from the cursor to eol
" author: Marc Weber

" blah<cursor>foo will return ["blah","foo"]
fun! vl#lib#buffer#splitlineatcursor#SplitCurrentLineAtCursor()
  let pos = col('.') -1
  let line = getline('.')
  return [strpart(line,0,pos), strpart(line, pos, len(line)-pos)]
endfunction
