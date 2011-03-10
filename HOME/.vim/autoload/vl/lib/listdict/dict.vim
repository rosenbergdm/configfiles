"|fld   description : Some helper functions to work with dictionaries
"|fld   keywords : <+ this is used to index / group scripts ?+> 
"|fld   initial author : <+ script author & email +>
"|fld   mantainer : author
"|fld   started on : 2006 Oct 29 19:10:32
"|fld   version: 0.0
"|fld   dependencies: <+ vim-python, vim-perl, unix-tool sed, ... +>
"|fld   contributors : <+credits to+>
"|fld   tested on os : <+credits to+>
"|fld   maturity: unusable, experimental
"|fld     os: <+ remove this value if script is os independent +>
"|
"|H1__  Documentation
"|
"|p     <+some more in depth discription
"|+     <+ joined line ... +>
"|p     second paragraph
"|H2_   typical usage
"|H3    plugin-file
"|pl    " <+ description +>
"|      <+ plugin command +>
"|
"|      " <+ description +>
"|      <+ plugin mapping +>
"|H3    ftp-file
"|ftp   " <+ description +>
"|     <command -nargs=0 -buffer XY2 :echo "XY2"
"|
"|H2__  settigns
"|set   <description of setting(s)>
"|      "description

"|func Does dictionary has the key key?
function! vl#lib#listdict#dict#HasKey(dict, key)
  return exists('a:dict['.string(a:key).']')
endfunction

"|func returns value from dict or default if key isn't present
function! vl#lib#listdict#dict#KeyValue(dict, key, default)
  if vl#lib#listdict#dict#HasKey(a:dict, a:key)
    return a:dict[a:key]
  else
    return a:default
  endif
endfunction

"|func empties a dictionary
function! vl#lib#listdict#dict#EmptyDict(dict)
  for key in keys(a:dict)
    call remove(a:dict, key)
  endfor
endfunction
