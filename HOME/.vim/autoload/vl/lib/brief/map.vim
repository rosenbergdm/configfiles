"|fld   description : execute one command for each list element
"|fld   keywords : map, brief 
"|fld   initial author : Marc Weber marco-oweber@gmx.de
"|fld   mantainer : author
"|fld   started on : 2006 Nov 11 20:29:19
"|fld   version: 0.0

"|func example usage
"|     call vl#lib#brief#map#MapCommand(range(1, 10), "exec 'echo \"square of '.val.' is '.val*val.'\"'")
function! vl#lib#brief#map#MapCommand(list, command)
  for val in a:list
    exec a:command
  endfor
endfunction

"function! vl#lib#brief#map#DoMap(map,buffer,chars,command)
  "exec a:map.' '.a:buffer.' '.a:chars.' 'vl#lib#conversion#string#EscapCmd(a:command)
"endfunction

" no longer any hassle with things like
" map <buffer> chars :call echo 'here comes a ugly separating bar | seen it'<cr>
"function! vl#lib#brief#map#AddBriefMappingCommands()
  "command -nargs=* Nnmb call vl#lib#brief#map#DoMap('nnoremap','<buffer>',<f-args>)
"endfunction
