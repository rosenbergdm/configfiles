"|fld   description : automate some tasks depending on cursor position inserting closing brackets etc)
"|fld   keywords : contexct sensitive completion 
"|fld   initial author : Marc Weber marco-oweber@gmx.de
"|fld   mantainer : author
"|fld   started on : 2006 Dec 16 22:54:18
"|fld   version: 0.0
"|fld   dependencies: <+ vim-python, vim-perl, unix-tool sed, ... +>
"|fld   contributors : <+credits to+>
"|fld   tested on os : <+credits to+>
"|fld   maturity: unusable, experimental
"|fld     os: <+ remove this value if script is os independent +>
"|
"|H1__  Documentation
"|p     See documentation of source file. This file is undergoing some changes
"|      !!!!!!!!!!!!!!!!! BE WARNED, quoting is a mess by now! 
"|      Instead of "abc a" use "abc\ a" else it won't work.
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
"let s:setting=vl#lib#vimscript#scriptsettings#Load('vl.lib.completion.contextcompletion.<+setting_name+>',<+ default +>)
"|
"|
"|hist <+ historical information. (Which changes have been made ?) +>
"|
"|TODO:  <+ its a good start to write a list to do first+>
"|+      
"|+      
"|+      
"|rm roadmap (what to do, where to go?)


" script-purpose: add context sensitiv completion (the first completion item
" is used by now.. but shouldn't be hard to modify)
" author: Marc Weber
" started : Sat Sep 16 08:04:31 CEST 2006
" stabilitiy : Works well. I'm using it regularely
" TODO: tidy up, replacee new_line_completion_list with
" two seperate things (complete end of line and start new line)

" usage :
"    initialize ( create lists an mappings)
" call vl#lib#completion#contextcompletion#InitContextCompletion(1)
"imap <buffer> <tab>
"<c-r>=vl#lib#completion#contextcompletion#ContextCompletion(b:completion_list,"")<cr>
"imap <buffer> <cr>
"<c-r>=vl#lib#completion#contextcompletion#ContextCompletion(b:new_line_completion_list,"\<lt>cr>")<cr>

"    shortcut
" let s:Cd = function('vl#textediting#contextcompletion#CompletionDict')
"    add value to completion  list. This completes f to function<space> if it's
"    the first word in its line
" call add(b:completion_list, s:Cd('^\s*f$','','unction','ts'))

" initialize completionlists
function! vl#lib#completion#contextcompletion#InitContextCompletion(list)
  for l in a:list
    exec "command! -buffer -nargs=* Add".l[0]."Completion "
     \ ":exec \"call vl#lib#completion#contextcompletion#CompletionDict(".string(l[2]).", \".join([<f-args>],', ').\",', ')\""
    let nomatch = len(l)>3 ? ','.vl#lib#conversion#string#ToDoubleQuotedString(l[3]) : ""
    exec 'inoremap <buffer> '.l[1].' <c-r>=vl#lib#completion#contextcompletion#ContextCompletion('.string(l[2]).nomatch.')<cr>'
  endfor
  let b:init_context_completion = a:list
endfunction

" entries must have one of the following forms:
" dict, values
" bcm = regex before cursor match
" acm = regex after cursor match
" bcnm = regex before cursor no match
" acnm = regex after cursor no match
" cf: completion function function (before,aftercursor) returning complettions
" cs: completion string which will be inswerted 
"   cf and cs can be specified at the same time
" ls=1: include leading space (if it doesn't exist yet
" ts=1: include trailing space (if it doesn't exist yet)
" break=1: don't try other completions

" adds completion after regex bc which inserts leading spaces
" optional parameters: 'ls' or 'ts' or both for leading, trailing space
function! vl#lib#completion#contextcompletion#CompletionDict(dict,bcm,bcnm, completion, ...)
  if !exists(a:dict)
    exec 'let '.a:dict.' = []'
  endif
  let dict = {}
  if a:bcm!=""
    let dict['bcm'] = a:bcm
  endif
  if a:bcnm!=""
    let dict['bcnm'] = a:bcnm
  endif
  if type(a:completion) == 2
    let dict['cf'] = a:completion
  elseif type(a:completion) ==1
    let dict['cs'] = a:completion
  endif
  let i=1
  while i<=a:0
    " se ls, or ts
      let dict[a:{i}] = 1
      let i+=1
  endwhile
  exec 'call add('.a:dict.', dict)'
endfunction

" proposed mapping:
" imap <buffer> <tab>
" <c-r>=vl#lib#completion#contextcompletion#ContextCompletion()<cr>
" imap <buffer> <cr> <c-r>=NewLineCompletion()<cr>

function! vl#lib#completion#contextcompletion#ContextCompletion(completion_list,...)
  exec vl#lib#brief#args#GetOptionalArg("nomatch_return",string("\<c-o>:echoe 'no completion found'\<cr>"))
  if (!exists(a:completion_list))
    return nomatch_return
  endif
  exec 'let compl_list = '.a:completion_list
  let [before,after] = vl#lib#buffer#splitlineatcursor#SplitCurrentLineAtCursor()
  " insert leading/ trailing space when requested?
  let ls = before !~ '\s$'
  let ts = after !~ '^\s'
  let [ls,ts] = map([ls,ts],'vl#lib#brief#conditional#IfElse(v:val==1," ","")')
  let completions = []
  " cycle through all possibilities
  for l in compl_list
    let loop_compl = []
    " match
    if exists("l['bcm']") && before !~ l['bcm']
      continue
    endif
    if exists("l['acm']") && after !~ l['acm']
      continue
    endif
    " no match
    if exists("l['bcnm']") && before =~ l['bcnm']
      continue
    endif
    if exists("l['acnm']") && after  =~ l['acnm']
      continue
    endif

    if exists("l['cs']")
      call add(loop_compl,l['cs'])
    endif
    let  g:lc1=loop_compl
    if exists("l['cf']")
      let CompletionFunc = l['cf']
      let loop_compl += CompletionFunc(before, after)
    endif
    let  g:lc2=loop_compl
    if exists("l['ls']") " add leading space
      let loop_compl = map(loop_compl,string(ls).'.v:val')
    endif
    let  g:lc3=loop_compl
    if exists("l['ts']") " add trailing space
      let loop_compl = map(loop_compl,'v:val.'.string(ts))
    endif
    if exists("l['break']")
      let completions = loop_compl
      break
    else
      let completions += loop_compl
    endif
  endfor
  if len(completions) == 0
    return nomatch_return
  else 
    return vl#ui#userSelection#LetUserSelectIfThereIsAChoice(
      \ 'Which completion to use?', vl#lib#listdict#list#Unique(completions))
  endif
endfunction

"function! NewLineCompletion()
"  if !exists('b:new_line_completion_list')
"    return ""
"  endif
"  let [before,after] =
"  vl#lib#buffer#splitlineatcursor#SplitCurrentLineAtCursor()
"  let completions = []
"  for l in b:new_line_completion_list
"    if !before =~ l[0]
"      continue
"    endif
"    if len(l)=3 && !after =~ l[1]
"      continue
"    endif
"    Completion = l[len(l-1)]
"    if type(Completion) == 1 " string
"      let completions += Completion
"    elseif type(Completion) == 2 " funcref
"      let completions += Completion(before, after)
"    endif
"  endfor
"  if len(completions) > 1 
"    echo "using first comletion out of ".len(completions)
"  endif
"  " by now just use first entry
"  return completions[0]
"endfunction
