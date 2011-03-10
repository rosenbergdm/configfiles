"" brief-description : some conditional functions to shorten scripts
"" keywords : conditional functions
"" author : Marc Weber marco-oweber@gmx.de
"" started on :2006 Oct 05 02:11:04
"" version: 0.0

"| returns either if_value or else_value
function! vl#lib#brief#conditional#IfElse(condition,if_value,else_value)
  if a:condition
    return a:if_value
  else
    return a:else_value
  endif
endfunction

"| executes statement if condition is true
function! vl#lib#brief#conditional#If( condition, statement)
  if a:condition
    exec a:statement
  endif
endfunction
