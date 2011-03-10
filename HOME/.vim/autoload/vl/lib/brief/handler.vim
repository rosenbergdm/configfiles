"|fld   description : try some functions and return result of first function
"|+                   which succeeds
"|fld   keywords : <+ this is used to index / group scripts ?+> 
"|fld   initial author : Marc Weber marco-oweber@gmx.de
"|fld   mantainer : author
"|fld   started on : 2006 Nov 06 19:13:42
"|fld   version: 0.0
"|fld   dependencies: <+ vim-python, vim-perl, unix-tool sed, ... +>
"|fld   contributors : <+credits to+>
"|fld   tested on os : <+credits to+>
"|fld   maturity: unusable, experimental
"|fld     os: <+ remove this value if script is os independent +>
"|
"|H1__  Documentation
"|
"|p     See vl#lib#template#template for an example
"|
"|H2_   typical usage see Handle function

"|func
"|p     tries to feed different functions with the given value.
"|      and returns on sucess [1, returned_value]  
"|      otherwise [0, failure_messages]
"|p     All handler functions must return [1, value] on success, [0, "failure_message"] otherwise
"|p     example usage:
"|code  let [success, value] = Handle( value, [function('handler1'), function('handler2')])
function! vl#lib#brief#handler#Handle( value, handler_list)
  let failure_messages = []
  let value = "dummy assignment to be able to call unlet"
  for H in a:handler_list
    unlet value
    let [success, value] = H(a:value)
    if success
      return [1, value]
    else
      call add(failure_messages, 'handler '.string(H).' failed. message: '.string(value))
    endif
  endfor
  return [0, failure_messages]
endfunction

"|func calls a function with each argument of the list
"|+    when it succeeds the returned value is returned similar to Handle(..)
"|+    defined above
function! vl#lib#brief#handler#HandleList( value_list, handler)
  let failure_messages = []
  for item in a:value_list
    let H = a:handler
    let [success, value] = H(item)
    if success
      return [1, value]
    else
      call add(failure_messages, 'handler '.string(H).' failed. message: '.string(value))
    endif
    return [0, failure_messages]
endfunction

"|func  You can use this in combination with HandleList to find a executable.
"|p     example
"|code  let [success, executable_or_error_message] = vl#lib#brief#handler#HandleList( ['tags','exuberant-ctags']
"|                  \ , vl#dev#vimscript#vimfile#Function(vl#lib#brief#handler#IsExecutableHandlerfunc(filename)))
function! vl#lib#brief#handler#IsExecutableHandlerfunc(filename)
  let fn = expand(a:filename)
  if executable(fn)
    return [1, fn]
  else
    return [0, "not an executable or not in path ".fn]
  endif
endfunction
