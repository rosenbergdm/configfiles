"|fld   description: a) keep a cache of all registered module Main to jump to source code
"|+                  b) simple function completion
"|fld   keywords : haskell, completion 
"|fld   initial author : Marc Weber marco-oweber@gmx.de
"|fld   mantainer : author
"|fld   started on : 2006 Oct 11 04:50:31
"|fld   version: 0.2
"|fld   dependencies: hasktags, perhaps unix-cmd find
"|fld   tested on os : windows, linux
"|fld   maturity: beta
"|
"|H1__  Documentation of haskell coding aids
"|
"|
"|H2_   Introduction
"|p     You can
"|      jump to imported module when using
"|code  import A.B.C
"|p     by pressing gf.
"|p     you can complete functions and modules (when writing import
"|+     statements). It's sufficient to write ^DM$<completion-mapping> to get
"|+     Data.Maybe or gC to match function getContents.
"|
"|
"|H2_   How to use?
"|
"|H3    Jump to module source using gf:
"|ftp   " jumps to the import <module> file either by looking up the file from
"|+       cache or from filesystem
"|      call vl#ui#navigation#gfHandler#AddGFHandler("vl#dev#haskell#modules_list_cache_jump#GetPossibleImportHaskellFilenamesWithSameBase()")
"|      call vl#ui#navigation#gfHandler#AddGFHandler("vl#dev#haskell#modules_list_cache_jump#PathOfModule('^'.expand('<cWORD>').'$')")
"|
"|H3    Module Cache
"|p     What is it?
"|p     The module cache is a file containing a list of modules. This list is
"|+     used to get lists of imported functions and module completion.
"|ftp   " This command adds the current directory (:echo getcwd()) to the
"|        module directory cache. This means all .hs, lhs files will be added.
"|        This command can be used to update this directory. 
"|      command! -buffer -nargs=0 AddCurrentDirToModulCache :call vl#dev#haskell#modules_list_cache_jump#AddDirToModulCache(getcwd())<cr>
"|      " Do the same with given directory
"|      command! -buffer -nargs=1 -complete=file AddDirToModulCache :call vl#dev#haskell#modules_list_cache_jump#AddDirToModulCache(<f-args>)<cr>
"|      " update the whole cache (rescan all directories)
"|      command! -buffer -nargs=0 UpdateModuleCacheAll :call vl#dev#haskell#modules_list_cache_jump#RescanAll()<cr>
"|      " this command removes the current directory from cache
"|      command! -buffer -nargs=0 RemoveDirectoryFromCache :vl#dev#haskell#modules_list_cache_jump#call vl#dev#haskell#modules_list_cache_jump#RemoveDirectoryFromCache()
"|      " Really handy: Find module by vim regular expression and open file.
"|      command!-buffer -nargs=1 OpenModuleByRegex :call vl#dev#haskell#modules_list_cache_jump#OpenModuleByRegex(<f-args>)<cr>
"|
"|H3    function completion
"|p     You can use rCT to match runContT ... :)
"|      use ^rCT$ to match a function containing only the camel case letters CT
"|ftp   inoremap <buffer> <c-m-f> <c-r>=vl#lib#completion#useCustomFunctionNonInteracting#GetInsertModeMappingText('omnifunc','vl#dev#haskell#modules_list_cache_jump#CompleteFunction',"\<c-x>\<c-o>")<cr>
"|
"|H3    module completion
"|p     this needs the module cache
"|p     You can use ^CMS$ to match Control.Monad.State or MS$, too
"|ftp   inoremap <buffer> <c-m-m> <c-r>=vl#lib#completion#useCustomFunctionNonInteracting#GetInsertModeMappingText('omnifunc','vl#dev#haskell#modules_list_cache_jump#CompleteModuleImportName',"\<c-x>\<c-o>")<cr>
"|
"|ftp   " open module file in import statement
"|       noremap gf :call vl#ui#navigation#gfHandler#HandleGF()<cr>
"|
"|set   
"|       s:directories_to_scan contains list of directories to scan for modules
"|       s:modules_list_file filename containg module cache
"|       s:quick_match_expr  function to also match shortcuts. (gC = getContent 
"|
"|TODO:  wait for some feedback.
"|+      
"|
"|rm roadmap implement this all in haskell? add haskell support to vim? ...


" options:
" ========
let s:dirs='haskell.module_dirs_to_scan' " setting id
let s:directories_to_scan = vl#lib#vimscript#scriptsettings#Load(s:dirs,[''])
let s:modules_list_file = vl#lib#vimscript#scriptsettings#Load('permanent_memory',
  \ vl#settings#DotvimDir().'permament_memory').'/haskell_module_cache'
let s:module_regex='\(\w\+\.\)*\u\w*' "matches something like  A.B.Foo
let s:files_to_parse_having_same_module_name = vl#lib#vimscript#scriptsettings#Load('files_to_parse_having_same_module_name',
  \ 2)

" I need to do this call to source the file, function(' doesn't do it
call vl#lib#completion#quick_match_functions#AdvancedCamelCaseMatching('')
let s:quick_match_expr = vl#lib#vimscript#scriptsettings#Load('dev.haskell.function_quick_match',
   \ function('vl#lib#completion#quick_match_functions#AdvancedCamelCaseMatching') )

" implementation
" ==============

" this function searches the module A.Foo line, goes A.Foo directories back
" and searches from there for the module under the cursor. You can also use
" this to create a file
function! vl#dev#haskell#modules_list_cache_jump#GetPossibleImportHaskellFilenamesWithSameBase()
  let cword = expand('<cWORD>')
  let result = []
  let l = search('^module [^ ]\+')
  if l > 0
    let module_path = match(line(l),'module \zs[^ ]*\ze')
    let base = substitute(expand('%:h'),module_path.'\.l\=hs','','')
    if base!=''
      let base.='/'
    endif
    call add( result, base.substitute(cword,'\.','/','').'.hs' )
    call add( result, base.substitute(cword,'\.','/','').'.lhs' )
  endif
  return result
endfunction

function! vl#dev#haskell#modules_list_cache_jump#RemoveDirectoryFromCache()
  let directory = vl#ui#userSelection#LetUserSelectOneOf("Which directory do you want to be removed", s:directories_to_scan)
  if directory == ""
    throw "user abort"
  endif
  call vl#lib#vimscript#scriptsettings#RemoveValueFromList(s:dirs, directory)
  let s:directories_to_scan = vl#lib#vimscript#scriptsettings#Load(s:dirs,[''])
  call vl#dev#haskell#modules_list_cache_jump#UpdateDir(directory,"remove")
endfunction


function! vl#dev#haskell#modules_list_cache_jump#AddDirToModulCache(dir)
  call vl#lib#vimscript#scriptsettings#AddValueToListUnique(s:dirs, a:dir)
  let s:directories_to_scan = vl#lib#vimscript#scriptsettings#Load(s:dirs,[''])
  echo "list contains now ".join(s:directories_to_scan,", ")
  echo "updating list, Ctrl-c to cancel"
  call vl#dev#haskell#modules_list_cache_jump#UpdateDir(a:dir,"add")
endfunction

" action on of add remove
function! vl#dev#haskell#modules_list_cache_jump#UpdateDir(dir,action)
  let cache = vl#lib#files#filefunctions#ReadFile(s:modules_list_file,[])
  echo "cache contains ".len(cache)." entries before having filtered entries"
  call filter(cache,"v:val!~';".a:dir."'") " remove old entries
  echo "cache contains ".len(cache)." entries after having filtered entries"
  if a:action == "add"
    echo "cache contains ".len(cache)." entries before adding entries"
    call s:AddModulesInDirToCache(cache, a:dir)
    echo "cache contains ".len(cache)." entries after adding entries"
  endif
  call vl#lib#files#filefunctions#WriteFile(cache, s:modules_list_file)
endfunction

" Rescans all directories .. might take quite a while
function! vl#dev#haskell#modules_list_cache_jump#RescanAll()
  let cache = []
  for dir in s:directories_to_scan
    call s:AddModulesInDirToCache(cache, dir)
  endfor
  call vl#lib#files#filefunctions#WriteFile(cache, s:modules_list_file)
endfunction

" Scans directory to add modules
function! s:AddModulesInDirToCache(cache,dir)
    echo "scanning for files in ".a:dir."..."
    let files = split(globpath(expand(a:dir),'**/*.*hs'),"\n") " get all haskell module files
    echo "got list of files, scanning content of ".len(files)."files  ..."
    for file in files
      let f = readfile(file)
      let line = filter(f,"v:val=~'module\\s*".s:module_regex."'")
      if len(line) == 0
	continue
      endif
      let module=matchstr(line[0],s:module_regex)
      call add(a:cache, module.';'.file)
    endfor
endfunction

" requieres module in form A.B.Mod
" returns list of matching filenames
" surround module by ^;.. eg search for "^IO;"
" optional arg not given or "yes" means use cache and only return
" s:files_to_parse_having_same_module_name entries
function! vl#dev#haskell#modules_list_cache_jump#PathOfModule(module,...)
  exec vl#lib#brief#args#GetOptionalArg("limit",string( "yes"))
  if limit == "yes"
    if !exists('g:path_of_module_cache')
      let g:path_of_module_cache = {}
    endif
    if exists("g:path_of_module_cache[".string(a:module)."]")
      return g:path_of_module_cache[a:module]
    endif
  endif
  let regex = substitute(substitute(a:module,'\$$',';',''),
		    \ '[^;]$','.*;','')
  "let file = vl#lib#files#filefunctions#ReadFile(s:modules_list_file,[])
  let file = vl#lib#files#scan_and_cache_file#ScanIfNewer(s:modules_list_file, s:ScanFuncModuleListe, 0)
  let file = deepcopy(file)
  let result = map(filter(file, "v:val =~ ".string(regex)),"substitute(v:val,'^[^;]*;','','')")

  if limit == "yes"
    let result = vl#lib#listdict#list#TrimListCount(result , s:files_to_parse_having_same_module_name)
    let g:path_of_module_cache[a:module] = result
  endif
  return result
  "let file = vl#lib#files#filefunctions#ReadFile( s:modules_list_file , [] )
  "let result = []
  "for l in file
    "let [ module, path ] = split(l, ';')
    "if module =~ a:module
      "call add(result, path)
    "endif
  "endfor
  "return result
endfunction

" this looks for a module in the A.B.Foo part using regular expressions. The
" selected module will be opened
function! vl#dev#haskell#modules_list_cache_jump#OpenModuleByRegex(RegExpr)
  let files = vl#dev#haskell#modules_list_cache_jump#PathOfModule(a:RegExpr)
  if len(files) ==  0
    echo "no match found"
  else
    if len(files) == 1
      let file = files[0]
    else
      let file = vl#ui#userSelection#LetUserSelectOneOf("Open which module?", files)
    endif
    exec 'e '.file
  endif
endfunction

function! vl#dev#haskell#modules_list_cache_jump#CompleteModuleImportName(findstart,base)
  if a:findstart
    " locate the start of the word
    let [bc,ac] = vl#lib#buffer#splitlineatcursor#SplitCurrentLineAtCursor()
    return len(bc)-len(matchstr(bc,'\%(\a\|\.\|\$\|\^\)*$'))
  else
    let base = substitute(a:base,'\.','\\.','g')
    let pat2 = '^'.substitute(substitute(a:base,'\([^$^]\)','\\.\1[^.]*','g'),'^\^\=\zs..\ze','','')
  
    let file = vl#lib#files#filefunctions#ReadFile( s:modules_list_file , [] )
    let file = map(file, "substitute(v:val,';.*','','')")
    let pat = "matchstr(v:val,'^".base."[^.]*\\.\\=')"
    let files = filter(map(deepcopy(file),pat),'v:val!=""')
    let files2 = filter(file , " v:val=~'".pat2."'")
    return files  + files2 + s:CompleteModules(0, a:base)
  endif
endfun

" will only complete modules from the current directory is invoked by
" vl#dev#haskell#modules_list_cache_jump#CompleteModuleImportName
fun! s:CompleteModules(findstart, base)
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '[^ ]'
      let start -= 1
    endwhile
    return start
  else
    " find months matching with "a:base"
    let globpattern = substitute(a:base,'\.','/','g')
    let globpattern = substitute(globpattern,'/$','','')
    let  g:gp=globpattern
    if isdirectory(globpattern)
      let globpattern .= '/*'
    else
      let globpattern .= '*'
    endif
    let files = split(glob(globpattern),"\n")
    let folders = filter(files,'isdirectory(v:val) || v:val =~ "\.l\\=hs$"')
    let folders = map(folders,'substitute(v:val,"\/",".","g")')
    let folders = map(folders,'substitute(v:val,"\\.l\\=hs","","")')
    return folders
  endif
endfunction


" function completion / beta ..
" documentation : This should complete functions defined in the same file and
" from imported file.. It's not perfect but shoud save you much time,
" import export restriction won't be implemented
" Origininally I hoped to implement this in haskell but this seems to be more
" effort ?
"
" A.C try complete from module A.B..C or from qualified import
" A.C try 
"
" TODO: What todo with local functions?

function! vl#dev#haskell#modules_list_cache_jump#CompleteAddMatchingFunctions(regex1, quickRegex, scanned_file, prefix, module, file)
  let functionlist = a:scanned_file['defined_functions']
  "debug echoe "checking functions".string(a:functionlist)
  let quick_matches = filter(deepcopy(functionlist),"v:key =~ ".string(a:quickRegex))
  let matches = filter(deepcopy(functionlist),"v:key =~ ".string(a:regex1))
  let dict = extend(quick_matches, matches)
  " map(,"'".a:prefix."'.v:val") 
  for m in keys(dict)
    let d = {'word': m, 'menu': a:module} 
    let info = dict[m]
    let line=''
    if exists("info['impl']")
      let line .= ' implementation '.info['impl']
    endif
    if exists("info['type']")
      let line .= ' type header '.info['type']
    endif

    if exists("info['type_sig']")
      let d['info'] = 'defined in '.a:file.line."\n".info['type_sig']
    else
      let d['info'] = 'defined in '.a:file.line
    endif
    call complete_add(d)
  endfor
endfunction

function! vl#dev#haskell#modules_list_cache_jump#CompleteAddMatchingTypes(regex1, quickRegex, scanned_file, prefix, module, file)
  if !vl#lib#listdict#dict#HasKey(a:scanned_file,'types')
    return 
  else
    let types = a:scanned_file['types']
  endif
  "debug echoe "checking functions".string(a:functionlist)
  let quick_matches = filter(deepcopy(types),"v:key =~ ".string(a:quickRegex))
  let matches = filter(deepcopy(types),"v:key =~ ".string(a:regex1))
  let dict = extend(quick_matches, matches)
  " map(,"'".a:prefix."'.v:val") 
  for m in keys(dict)
    let info = dict[m]
    let d = {'word': m, 'menu': printf('%10s %s', info['type'], a:module)}  
    call complete_add(d)
  endfor
endfunction

" completes haskell functions
function! vl#dev#haskell#modules_list_cache_jump#CompleteFunction(findstart,base)
  return vl#dev#haskell#modules_list_cache_jump#Complete(a:findstart, a:base
	\ , function('vl#dev#haskell#modules_list_cache_jump#CompleteAddMatchingFunctions'))
endfunction

function! vl#dev#haskell#modules_list_cache_jump#CompleteType(findstart,base)
  return vl#dev#haskell#modules_list_cache_jump#Complete(a:findstart, a:base
	\ , function('vl#dev#haskell#modules_list_cache_jump#CompleteAddMatchingTypes'))
endfunction

let s:max_levels = 5
function! vl#dev#haskell#modules_list_cache_jump#Complete(findstart,base, func)
  if a:findstart
    " locate the start of the word
    let [bc,ac] = vl#lib#buffer#splitlineatcursor#SplitCurrentLineAtCursor()
    return len(bc)-len(matchstr(bc,'\%(\a\|\.\|\$\|\^\)*$'))
  else
    let prefix = matchstr(a:base,'.*\.')
    let func = substitute(a:base,'.*\.','','')
    " matching patterns
    let quick_pattern = s:quick_match_expr(func)
    let pattern = '^'.func
    let [checked,to_check] = [{},[]]
    let this_buf = vl#dev#haskell#modules_list_cache_jump#ScanHaskellFile(getline(0, line('$')))
    let g:b = this_buf
    call a:func(pattern, quick_pattern, this_buf, prefix, 'current buffer', 'current buffer')
    let imports = vl#dev#haskell#modules_list_cache_jump#ImportedList(getline(0,line('$')))
    call extend(to_check, map(imports,"[v:val,1]"))
    let i=1
    let modules = []
    while len(to_check)>0
      "debug echoe "to check".string(to_check)
      if complete_check()
	return []
      endif
      " remove this module from todo list and add it to checked
      let [module, level] = to_check[0]
      call remove(to_check, 0)
      let g:checked=checked
      let g:to_check = module
      if exists("checked['".module."']")
	continue
      endif
      if level > s:max_levels
	continue
      endif
      let checked[module] = 1
      let files = vl#dev#haskell#modules_list_cache_jump#PathOfModule('^'.module.'$')
      if len(files)==0
	"debug echoe "a:module ".module." not found"
      elseif len(files) > 1
	"debug echoe "module '".module."' found more than once"
      endif
      for f in files
	if complete_check()
	  return []
	endif
	" scan file and add functions to completion list:
	"echo 'scanning'.f
	call add(modules, f)
	let scan_result = vl#lib#files#scan_and_cache_file#ScanIfNewer(f, s:ScanFunc)
	call a:func(pattern, quick_pattern, 
	      \ scan_result, prefix, module, f)
	"debug echoe "imports from module ".module." added ".string(scan_result['imports'])
	call extend(to_check, map(deepcopy(scan_result['imports']),'[v:val,'.string(level+1).']'))
	"debug echoe string(to_check)
	let i=i+1
	break " only use first file .. will take too much time else
      endfor
    endwhile
  let g:modules_taken_into_account_by_haskell_completion = keys(checked)
  return []
  endif
endfun

" ignoreFiles is a ";" separated list of files, also starting with ;
" follows imports wether there are explicit export directives or not
function! s:GetExposedFunctionsFromModule(module, ignoreFiles, level)
  if a:level==0
    return []
  endif
  "debug echoe "scanning ".a:module." ".string(files)
  if len(files)>0
    "echo "warning, more than one match for module '".a:module."', taking the first"
    let file_content = vl#lib#files#filefunctions#ReadFile(files[0],[])
    let functions = keys(vl#dev#haskell#modules_list_cache_jump#ScanModuleForFunctions(file_content))
    let imports = vl#dev#haskell#modules_list_cache_jump#ImportedList(file_content)
    let ignore = a:ignoreFiles.';'.a:module
    for i in imports
      if a:ignoreFiles =~ ';'.i.'\%($\|;\)'
	continue
      else
	let functions =  extend(functions, s:GetExposedFunctionsFromModule(i, ignore, a:level-1) )
      endif
    endfor
    return functions
endfunction

" returns a list of imported modules
" file is a list of lines
function! vl#dev#haskell#modules_list_cache_jump#ImportedList(file)
  return filter(map(deepcopy(a:file),"matchstr(v:val,'^\\s*import\\s*\\%(qualified\\)\\=\\s*\\zs".s:module_regex."\\ze')"),'v:val!=""')
endfunction

" todo : rewrite to recognize records data A = A { abc :: foo ..
"        and to add type declaration as well
function! vl#dev#haskell#modules_list_cache_jump#FunctionRegex()
  let dict = {}
  " pattern1 / 2 matches
  " we need to recognize :
  " 1) function_name arg1 arg2 =
  " 2) arg1 `function_name` arg2 =
  " 3) function_name :: type
  " data Foo = Foo { accessor :: type; ...
  let dict['func_name'] = '\%(\l\w*\)'
  " a@(Either a b )
  " b
  " both must be parsed. The quickest way is just many non whitespace chars
  " (doesn't match (A a) but doesn't matter as it is seen as \S\S \S\S thus
  " beeing to args.
  let dict['arg'] = '\S\+'
  " op a b =
  let dict['f_pattern1'] = '\zs'.dict['func_name'].'\ze\%(\s\+\%('.dict['arg'].'\)\)*\s*='
  " a `op` b
  let dict['f_pattern2'] = '\%('.dict['arg'].'\)\s*`\zs'.dict['func_name'].'\ze`\s*\%('.dict['arg'].'\)\s*='
  let dict['f_pattern'] = '^\s*\%(\%('.dict['f_pattern1'].'\)\|\%('.dict['f_pattern2'].'\)\)'
  return dict
endfunction

"func  scans the file for data type declarations (data, type, newtype)
" returns dictionary {name:{"type":linenr, "impl":linenr  } }
function! vl#dev#haskell#modules_list_cache_jump#ScanModuleForTypes(file)
  let line_nr = 1
  let pattern = '^\s*\%(data\|\%(new\)\=type\)\s*\zs\u\w*\ze'
  let result = {}
  while line_nr < len(a:file)
    let line = a:file[line_nr]
    if line =~ pattern
      let type_type = matchstr(line, '^\s*\zs\w*\ze')
      let name = matchstr(line, pattern)
      let result[name] = { 'type':type_type, 'linenr' : line_nr +1 }
    endif
    let line_nr = line_nr + 1
  endwhile
  return result
endfunction


" returns dictionary {name:{"type":linenr, "impl":linenr  } }
" type declaration isn't yet implemented
" file is a list of lines
function! vl#dev#haskell#modules_list_cache_jump#ScanModuleForFunctions(file)
  " a function is recognized as function if the looks like 
  " a b c = ...
  " and a is no keyword (data, new\=type, instance)
  let no_f_pattern = '\%(\%(\%(new\)\=type\)\|data\)'
  let func_r = vl#dev#haskell#modules_list_cache_jump#FunctionRegex()
  let type_pattern = '\('.func_r['func_name'].'\)\s*::[^;}]*'
  let g:t = type_pattern
  
  let result = {}

  let line_nr = 1
  while line_nr < len(a:file)
    try
      let line = a:file[line_nr]
      " check for function   name params =  or  param `name` param =
      if line =~ func_r['f_pattern'] && line !~ no_f_pattern
	let result[matchstr(line, func_r['f_pattern'])]={"impl": line_nr}
	continue
      endif
      " check for type signatures (::)
      let list = vl#lib#regex#regex#AllMatches(line,type_pattern)
      let dataType = matchstr(line, '\%(data\|newtype\)\s\+\zs\u\w*')
      let types = []
      if len(list) > 1
	let mid = remove(list, 0, len(list) - 2)
	for accessor in mid
	  let func_name = matchstr(accessor, func_r['func_name'])
	  let type = matchstr(accessor, '::\s*\zs[^;]*')
	  call add(types, [func_name, type, line_nr + 1])
	endfor
      endif
      if len(list) > 0
	let last = list[0]
	let func_name = matchstr(last, func_r['func_name'])
	let type = matchstr(last, '::\s*\zs[^;]*')
	" line continuation?
	while (line_nr < len(a:file) -1)
	  let next_line = a:file[line_nr+1]
	  if next_line  == '^\s\+'
	    let line_nr = line_nr +1
	    let type .= "\n".next_line
	  else
	    break
	  endif
	endwhile
	call add(types, [func_name, type, line_nr + 1])
      endif
      for [name, type , line] in types
	if len(dataType) > 0
	  let type = dataType . ' -> (' . type . ')'
	endif
	if exists("result['".func_name."']")
	  let result[func_name]['type'] = line_nr + 1
	  let result[func_name]['type_sig'] = type
	else
	  let result[func_name]={"type": line_nr + 1, 'type_sig': type}
	endif
      endfor
    finally
      let line_nr = line_nr + 1
    endtry
  endwhile
  return result
endfunction

" returns dictionary {name:{"type":linenr, "impl":linenr  } }
" type declaration isn't yet implemented
" file is a list of lines
function! vl#dev#haskell#modules_list_cache_jump#ScanModuleForFunctions_old(file)
  " a function is recognized as function if the looks like 
  " a b c = ...
  " and a is no keyword (data, new\=type, instance)
  let no_f_pattern = '\%(\%(\%(new\)\=type\)\|data\)'
  let func_r = vl#dev#haskell#modules_list_cache_jump#FunctionRegex()

  let result = {}
  for line_nr in range(0,len(a:file)-1)
    let line = a:file[line_nr]
    if line =~ no_f_pattern
      continue
    endif
    if line =~ func_r['f_pattern']
      let result[matchstr(line, func_r['f_pattern1'])]={"impl": line_nr}
    endif
  endfor
  
  " add type declarations.. doesn't recognize lists (a, b :: ) yet.
  " Is needed to get the function names eg of
  " newtype Cont r a = Cont { runCont :: (a -> r) -> r }
  let type_pattern = '\zs\('.func_r['func_name'].'\)\%(\s*,\s*\%('.func_r['func_name'].'\)\)*\ze\s*::'
  let g:tp = type_pattern
  let line_nr = 0
  while line_nr < len(a:file)
    let line = a:file[line_nr]
    if line =~ type_pattern
      let list = split(matchstr(line, type_pattern),'\s*,\s*')
      for func_name in list
	if exists("result['".func_name."']")
	  let result[func_name]['type'] = line_nr
	else
	  let result[func_name]={"type": line_nr}
	endif
      endfor
    endif
    let line_nr = line_nr + 1
  endwhile
  return result
endfunction

" this returns important information for complition (at the moment imported
" files and defined files)
function! vl#dev#haskell#modules_list_cache_jump#ScanHaskellFile(file_lines)
  "debug echo "scanning file ".a:file
  let imports = vl#dev#haskell#modules_list_cache_jump#ImportedList(deepcopy(a:file_lines))
  let functions = vl#dev#haskell#modules_list_cache_jump#ScanModuleForFunctions(a:file_lines)
  let types = vl#dev#haskell#modules_list_cache_jump#ScanModuleForTypes(a:file_lines)
  return {"imports": imports
       \ , "defined_functions" : functions
       \ , "types" : types}
endfunction

" I need to do this call to source the file, function(' doesn't do it
let s:ScanFunc = function('vl#dev#haskell#modules_list_cache_jump#ScanHaskellFile')
" load this function
call vl#lib#files#scan_and_cache_file#ScanFileContent("dummy arg")
let s:ScanFuncModuleListe = function('vl#lib#files#scan_and_cache_file#ScanFileContent')
