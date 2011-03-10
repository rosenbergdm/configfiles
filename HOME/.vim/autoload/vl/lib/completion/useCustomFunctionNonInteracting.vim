" script-purpose: use omni  completion with temporarely different completion
" func
" author: Marc Weber
" started : Sat Sep 16 08:07:21 CEST 2006
" stabilitiy : not well tested
" description:
" These function let you use omnifunc, opfunc or another function without
" intervening because it sets and restores the function collaborately
" TODO: seems to be slower than using set omnifunction directly .. why?

" Todo : add this example
" Date: Wed, 20 Sep 2006 22:41:58 +0200
"From: Martin Stubenschrott <stubenschrott@gmx.net>
"To: Vimdev <vim-dev@vim.org>
"Cc: Gautam Iyer <gautam@math.stanford.edu>
"Subject: Re: Keyword completion

"On Wed, Sep 20, 2006 at 01:33:54PM -0700, Gautam Iyer wrote:
"> Maybe this has been discussed already: When pressing Ctrl-P / Ctrl-N,
"> can we get vim to complete from the list of syntax keywords?

"You can do that by setting:

":set omnifunc=syntaxcomplete#Complete

"and then use <c-x><c-o>

"You can also specifiy certain syntax groups too use, but look into the
"docs/scripts, how to do that.

"--
"Martin

function! vl#lib#completion#useCustomFunctionNonInteracting#StoreUserFunction(vim_func_name,func_to_call)
  exec 'let g:stored_func = &'.a:vim_func_name
  exec 'let &'.a:vim_func_name.' = a:func_to_call'
  return ""
endfunction

function! vl#lib#completion#useCustomFunctionNonInteracting#RestoreUserFunction(vim_func_name)
  exec 'let &'.a:vim_func_name.' = g:stored_func'
  unlet g:stored_func
  return ""
endfunction

" example usage
" inoremap <buffer> <c-s>
" <c-r>=vl#lib#completion#useCustomFunctionNonInteracting#GetInsertModeMappingText('omnifunc',myomnifunc,"\<c-x>\<c-o>")<cr>
function! vl#lib#completion#useCustomFunctionNonInteracting#GetInsertModeMappingText(vim_func_name,func,characters_to_execute_in_insert_mode)
  let result = "\<c-r>=vl#lib#completion#useCustomFunctionNonInteracting#StoreUserFunction('".a:vim_func_name."',".string(a:func).")\<cr>"
  " now invoke completion
  let result .= a:characters_to_execute_in_insert_mode
  let result .= "\<c-r>=vl#lib#completion#useCustomFunctionNonInteracting#RestoreUserFunction('".a:vim_func_name."')\<cr>"
  return result
endfunction

" example usage (taken from vim help see :h map-operator
" map <leader>
function! vl#lib#completion#useCustomFunctionNonInteracting#NormalModeMapping(vim_func_name,func,characters_to_execute_in_normal_mode)
  exec 'let g:stored_func = &'.a:vimfunc
  exec 'let &o'.a:vimfunc.' = a:func_to_call'
  exec 'normal '.a:characters_to_execute_in_normal_mode
  exec 'let &'.a:vimfunc.' = g:stored_func'
  unlet g:stored_func
endfunction

function! vl#lib#completion#useCustomFunctionNonInteracting#ReadMovement()
  let result = ''
  let c = getchar()
  while c >= char2nr('0') and c <= char2nr('9')
    let return .= nr2char(c)
  endwhile
  let movement=['w','e','0','gg','G','h','j','k','l,'$','_',"\n",'%']
  let m=''
  let c = getchar()
endfunction

"============ NormalModeMapping example ========================================
" taken from vimhelp, see opfunc
let mapleader = ","
vmap <silent> <leader>cs :call vl#lib#completion#useCustomFunctionNonInteracting#NormalModeMapping('opfunc<CR<g@',function(vl#lib#completion#useCustomFunctionNonInteracting#CountSpaces(visualmode(), 1)),':<c-u>call vl#lib#completion#useCustomFunctionNonInteracting#CountSpaces(visualmode(),1)<cr>')<c-r>
nmap <silent> <F4> :set opfunc=CountSpaces<CR>g@
vmap <silent> <F4> :<C-U>call vl#lib#completion#useCustomFunctionNonInteracting#CountSpaces(visualmode(), 1)<CR>

function! vl#lib#completion#useCustomFunctionNonInteracting#CountSpaces(type, ...)
  let sel_save = &selection
  let &selection = "inclusive"
  let reg_save = @@

  if a:0  " Invoked from Visual mode, use '< and '> marks.
    silent exe "normal! `<" . a:type . "`>y"
  elseif a:type == 'line'
    silent exe "normal! '[V']y"
  elseif a:type == 'block'
    silent exe "normal! `[\<C-V>`]y"
  else
    silent exe "normal! `[v`]y"
  endif

  echomsg strlen(substitute(@@, '[^ ]', '', 'g'))

  let &selection = sel_save
  let @@ = reg_save
endfunction

"============ InsertModeMapping example ========================================
" taken from vimhelp, see :h complete-functions
"inoremap <buffer> <leader>m <c-r>=vl#lib#completion#useCustomFunctionNonInteracting#GetInsertModeMappingText('omnifunc','CompleteMonths',"\<c-x>\<c-o>")<cr>
fun! vl#lib#completion#useCustomFunctionNonInteracting#CompleteMonths(findstart, base)
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\a'
      let start -= 1
    endwhile
    return start
  else
    " find months matching with "a:base"
    let res = []
    for m in split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec")
      if m =~ '^' . a:base
	call add(res, m)
      endif
    endfor
    return res
  endif
endfun
fun! vl#lib#completion#useCustomFunctionNonInteracting#CompleteMonthsSlow(findstart, base)
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\a'
      let start -= 1
    endwhile
    return start
  else
    " find months matching with "a:base"
    let i = 0
    while 1
      call complete_add(i)
      if complete_check()
	echoe "c 1"
	break
      endif
      let i = i+1
      sleep 300m	" simulate searching for next match
    endwhile
  endif
endfun
"inoremap <m-t><m-t> <c-r>=vl#lib#completion#useCustomFunctionNonInteracting#GetInsertModeMappingText('omnifunc','vl#textediting#omni#useCustomFunctionNonInteracting#CompleteMonthsSlow',"\<c-x>\<c-o>")<cr>
"set completefunc=vl#textediting#omni#useCustomFunctionNonInteracting#CompleteMonths
"set completefunc=vl#textediting#omni#useCustomFunctionNonInteracting#CompleteMonthsSlow
"set omnifunc=vl#textediting#omni#useCustomFunctionNonInteracting#CompleteMonthsSlow

