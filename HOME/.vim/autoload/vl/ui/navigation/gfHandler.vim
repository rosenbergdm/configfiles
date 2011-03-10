"|fld   description : jumpt to files/ file locations using gf
"|fld   keywords : gf 
"|fld   initial author : Marc Weber marco-oweber@gmx.de
"|fld   mantainer : author
"|fld   started on : 2006 Nov 02 03:11:21
"|fld   version: 0.0
"|fld   contributors : <+credits to+>
"|fld   tested on os : <+credits to+>
"|fld   maturity: stable
"|
"|H1__  Documentation
"|
"|p     This small script provides the possibility to customize gf by adding
"|+     your own gf mapping handlers.
"|p     Each handler should return a list of files (mostly created by
"|      extracting the file under the cursor (See examples)
"|p     If only one of the files from all handlers exist it will be opened
"|p     If more than one exists or none a list will be shown so that you can choose 
"|+     the file to edit/create.
"|p     If the file doesn't exist you can edit it anyway. (I think pressing
"|+     <c-o> is faster then typing :e <I want to edit this file anyway!> ;-)
"|
"|H2_   The gf handler
"|p     The handler must be a string (executed by exec) or a function (not yet implemented)
"|+     returning either a filename as string or [filename, line_nr] to jump to
"|H2    Usage: (simplified example I'm using for opening modules in from
"|      when editing haskell files)
"|ftp   noremap gf :call vl#ui#navigation#gfHandler#HandleGF()<cr>
"|      call vl#ui#navigation#gfHandler#AddGFHandler("[substitute(expand('<cWORD>'),'\\.','/','g').'\.hs']")
"|      call vl#ui#navigation#gfHandler#AddGFHandler("[substitute(expand('<cWORD>'),'\\.','/','g').'\.lhs']")

"|func  adds another gf handler belonging to this buffer
"|p     Example:
"|code  call vl#ui#navigation#gfHandler#AddGFHandler("[substitute(expand('<cWORD>'),'\\.','/','g').'\.lhs']")
function! vl#ui#navigation#gfHandler#AddGFHandler(handler)
  call vl#lib#vimscript#scriptsettings#GetOrDefine('b:gf_handler',string([]))
  call add(b:gf_handler,a:handler)
endfunction

function! s:DoesFileExist(value)
  if type(a:value) == 1
    let filename = a:value
  else
    let filename = a:value[0]
  endif
  return filereadable(expand(filename))
endif
endfunction

function! s:GotoLocation(value)
  if type(a:value) == 1
    if a:value == ""
      return 
    endif
    let filename = a:value
    let line_nr = -1
  else
    let filename = a:value[0]
    let line_nr = a:value[1]
  endif
  exec ":e ".filename
  if line_nr >= 0
    exec line_nr
  endif
endfunction

function! s:ParseItemStr(value)
  if a:value =~ ', line '
    let line = matchstr('\d*$',a:value)
    return [ substitute(a:value,', line .*','',''), line ]
  else
    return a:value
  endif
endfunction
  
function! s:ToItemStr(value)
  if type(a:value) == 1
    return a:value
  else
    return a:value[0].', line '.a:value[1]
  endif
endfunction

"|func  Use this function in your mapping in a ftplugin file like this:
"|code  noremap gf :call vl#ui#navigation#gfHandler#HandleGF()<cr>
function! vl#ui#navigation#gfHandler#HandleGF()
  let pos = getpos('.')
  let possibleFiles = []
  if exists('b:gf_handler')
    for h in b:gf_handler
      call setpos('.',pos)
      exec 'let possibleFiles += '.h
    endfor
  endif
  " let possibleFiles += s:DefaultHandler()
  " if one file exists use that
  let existingFiles = filter(deepcopy(possibleFiles), 's:DoesFileExist(v:val)')
  if len(existingFiles) == 1
    call s:GotoLocation(existingFiles[0])
  elseif len(existingFiles) > 1
    call s:GotoLocation(s:ParseItemStr(vl#ui#userSelection#LetUserSelectOneOf(
      \ "which file do you want to edit?", 
      \ map(existingFiles, 's:ToItemStr(v:val)'))))
  elseif len(possibleFiles) == 1
     call s:GotoLocation(possibleFiles[0])
  elseif len(possibleFiles) > 1
     call s:GotoLocation(s:ParseItemStr(vl#ui#userSelection#LetUserSelectOneOf(
      \ "which file do you want to edit?", 
      \ map(possibleFiles, 's:ToItemStr(v:val)'))))
  else
    echo "no file found"
  endif
endfunction 

function! s:GetFileFromList(list)
  if len(a:list) == 1
    return a:list[0]
  else
    let index=inputlist(["Select the file to open/create"] + a:list)
    if index == 0
      return ""
    else
      return a:list[index-1]
    endif
  endif
endfunction

function! s:DefaultHandler()
  return [expand('<cfile>')]
endfunction
