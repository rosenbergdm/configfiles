"|fld   description : <+ really short description to get a picture. less than 2 sentences if possible +>
"|fld   keywords : <+ this is used to index / group scripts ?+> 
"|fld   initial author : Marc Weber marco-oweber@gmx.de
"|fld   mantainer : author
"|fld   started on : 2007 Feb 08 12:50:19
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
"|
"|pl    " <+ description +>
"|      <+ plugin command +>
"|
"|      " <+ description +>
"|      <+ plugin mapping +>
"|
"|ftp   " <+ description +>
"|     <command -nargs=0 -buffer XY2 :echo "XY2"
"|
"|H2__  settings
"|set   <description of setting(s)>
"|      "description
"|
"|
"|hist <+ historical information. (Which changes have been made ?) +>
"|
"|TODO:  <+ its a good start to write a list to do first+>
"|+      
"|+      
"|+      
"|rm roadmap (what to do, where to go?)


" in contrast to string() this function escapes using "
" not complete
function! vl#lib#conversion#string#ToDoubleQuotedString(str)
  return '"'.vl#lib#conversion#string#QuoteBackslashSpecial(a:str).'"'
endfunction

function! vl#lib#conversion#string#QuoteBackslashSpecial(str)
  let subst = [ 
	    \   ['\\'  ,'\\\\']
            \ , ["\r" ,'\\r']
	    \ , ["\t" ,'\\t']
	    \ ]
  let s = a:str
  for su in subst
    let s = substitute(s, su[0], su[1] ,'g')
  endfor
  return s
endfunction

function! vl#lib#conversion#string#EscapCmd(string)
  return substitute(a:string,'|','\|','g')
endfunction
