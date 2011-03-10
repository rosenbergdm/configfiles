"" brief-description : Some util functions processing lists
"" keywords : list 
"" author : Marc Weber marco-oweber@gmx.de
"" started on :2006 Oct 02 05:42:31
"" version: 0.0

"|func returns last value of list or value_if_empty if list is empty
function! vl#lib#listdict#list#Last(list, value_if_empty)
  let len = len(a:list) 
  if len == 0
    return a:value_if_empty
  else
    return a:list[len-1]
  endif
endfunction

function! vl#lib#listdict#list#MaybeIndex(list, index, default)
  if a:index>=0 && a:index < len(a:list)
    return a:list[a:index]
  else
    return a:default
  endif
endfunction

function! vl#lib#listdict#list#ListContains(list, value)
  for v in a:list
    if v == a:value
      return 1
    endif
  endfor
  return 0
endfunction

function! vl#lib#listdict#list#AddUnique(list, value)
  if !vl#lib#listdict#list#ListContains(a:list, a:value)
    return add(a:list, a:value)
  else
    return a:list
  endif
endfunction

function! vl#lib#listdict#list#Unique(list)
  let result = {}
  for v in a:list
    let result[v]=0 " this will add the value only once
  endfor
  return keys(result)
endfunction

"|func joins the list of list ( [[1,2],[3,4]] -> [1,2,3,4] )
function! vl#lib#listdict#list#JoinLists(list_of_lists)
  let result = []
  for l in a:list_of_lists
    call extend(result, l)
  endfor
  return result
endfunction

" is there a better way to do this?
" using remove?
function! vl#lib#listdict#list#TrimListCount(list, count)
  let c = 0
  let result = []
  for i in a:list
    if c >= a:count 
      break
    endif
    call add(result, i)
    let c = c+1
  endfor
  return result
endfunction

function! vl#lib#listdict#list#MapCopy(list, expr)
  let result = []
  for val in a:list
    exec 'call add(result, '.a:expr.')'
  endfor
  return result
endfunction

function! vl#lib#listdict#list#Zip(...)
  let a = a:000
  let c = min( vl#lib#listdict#list#MapCopy(a,'len(val)'))
  let r = range(0,a:0-1)
  let result = []
  for i in range(0,c-1)
    let l = []
    for j in r
      call add(l,a[j][i])
    endfor
    call add(result,l)
  endfor
  return result
endfunction

function! vl#lib#listdict#list#Transpose(a)
  let max_len = max( vl#lib#listdict#list#MapCopy(a:a, 'len(val)')
  let result = []
  for i in range(0, max_len - 1)
    let l = []
    for j in len(a:a)
      call add(result,a:a[j][i])
    endfor
    call add(result, l)
  endfor
  return result
endfunction

"func 
"pre  ['a','bbbbb','c']
"     ['AAAAaa','B','C']
"/pre is aligned this way:
"pre  ['a     ','bbbbb','c']
"     ['AAAAaa','B    ','C']
"/pre this way
function! vl#lib#listdict#list#AlignToSameIndent(a)
  "let result = a:a
  "call map(result,"map(v:val,'substitute(v:val,\"^\\s*\\|\\s*$\",\"\",\"g\")')")
  let result = []
  for i in range(0, len(a:a) -1 )
    let l = []
      for j in range(0, len(a:a[i]) -1 )
      call add(l, substitute(a:a[i][j],'^\s*\|\s*$','','g'))
    endfor
    call add(result, l)
  endfor
  let max_len = max( vl#lib#listdict#list#MapCopy(result, 'len(val)'))
  for i in range(0, max_len -1)
    let max = -1
    for j in range(0, len(result)-1)
      let c = strlen(vl#lib#listdict#list#MaybeIndex(result[j] , i,''))
      if c > max
        let max = c
      endif
    endfor
    for j in range(0, len(result) -1)
      if i < len(result[j])
        let v = result[j][i]
        let result[j][i] = repeat(' ',max-strlen(v)) . v
      endif
    endfor
  endfor
  return result
endfunction
