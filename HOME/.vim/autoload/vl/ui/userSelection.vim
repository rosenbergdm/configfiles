"|fld   description : some abstraction on input list
"|fld   keywords : "choose item from list" 
"|fld   initial author : Marc Weber marco-oweber@gmx.de
"|fld   mantainer : author
"|fld   started on : 2006 Nov 15 00:52:16
"|fld   version: 0.0
"|fld   contributors : <+credits to+>
"|fld   tested on os : <+credits to+>
"|fld   maturity: stable
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
"|      use this option to not use input list but getchar.
"|      Thus you can just type 1/2 ...  01/02 .. 10 instead of 1<cr>
let s:use_getchar=vl#lib#vimscript#scriptsettings#Load('vl.ui.userSelection.use_getchar',1)
"1
"|
"|hist <+ historical information. (Which changes have been made ?) +>
"|
"|TODO:  <+ its a good start to write a list to do first+>
"|+      
"|+      
"|+      
"|rm roadmap (what to do, where to go?)
"
" I could imagine showing the items in a buffer and providing a continuation
" function..  I need more time to implement it ;)

"|func the same as inputlist except that it uses getchar if option is set.
"|+    This way you don't have to type the return key
function! vl#ui#userSelection#Inputlist(list)
  if s:use_getchar
    echo join(a:list,"\n")
    echo "choose a number :"
    let answer = ''
    for i in range(1,len(string(len(a:list))))
      let c = getchar()
      if c == 13 
	break
      endif
      let answer .= nr2char(c)
    endfor
    let g:answer = answer
    if len(matchstr(answer, '\D')) > 0
      return 0
    else
      return answer
    endif
  else
    return inputlist(a:list)
  endif
endfunction

"|func  returns: item by default
"|      optional parameter: "return index" to return the index instead of the value
"|                          "return both" t return both ([index,item]  [-1,""] in case of no selection )
function! vl#ui#userSelection#LetUserSelectOneOf(caption, list, ...)
  let list_to_show = [a:caption]
  " add numbers
  for i in range(1,len(a:list))
    call add(list_to_show, i.') '.a:list[i-1])
  endfor
  let index = vl#ui#userSelection#Inputlist(list_to_show)
  if index == 0
    let result = [ -1,  ""]
  else 
    let result = [index -1, a:list[index -1] ]
  endif
  if a:0 > 0
    if a:1 == "return index"
      return result[0] " return index
    else
      return result " return both
    endif
  else
    return result[1] "return item
  endif
endfunction

"|func if list contains more than one item let the user select one
"|     else return the one item
function! vl#ui#userSelection#LetUserSelectIfThereIsAChoice(caption, list, ...)
  if len(a:list) == 0
    throw "LetUserSelectIfThereIsAChoice: list has no elements"
  elseif len(a:list) == 1
    return a:list[0]
  else
    if a:0 > 0 
      return vl#ui#userSelection#LetUserSelectOneOf(a:caption, a:list, a:1)
    else
      return vl#ui#userSelection#LetUserSelectOneOf(a:caption, a:list)
  endif
endfunction

" is a stub which can be used
" returns a list instead compared to SeletOneOf (copied)
function! vl#ui#userSelection#LetUserSelectMany(caption, list, ...)
  let list_to_show = [a:caption]
  " add numbers
  for i in range(1,len(a:list))
    call add(list_to_show, i.') '.a:list[i-1])
  endfor
  let index = vl#ui#userSelection#Inputlist(list_to_show)
  if index == 0
    let result = [ -1,  ""]
  else 
    let result = [index -1, a:list[index -1] ]
  endif
  if a:0 > 0
    if a:1 == "return index"
      return [result[0]] " return index
    else
      return [result] " return both
    endif
  else
    return [result[1]] "return item
  endif
endfunction
