" script-purpose: store/ restore script settings in one place/ file
" author: Marc Weber (marco-oweber@gmx.de)
" started : Mon Sep 18 07:12:45 CEST 2006
" description: Its not a very good idea to store script settings in the
" script file.. because you might update them and you'll have to copy your
" settings. This implementation tries to improve this by providing a small
" interface to load/ save custom settings in a unique file..
"
" Todo: Implement set setting
" a) Set<SettnigName> <value>
" b) Set <settingname> <value>
"
" proposed usage: 
" * see let g:settings_file below,
" * let s:setting = vl#lib#vimscript#scriptsettings#Load('script.settingname',default)
" * let s:setting = CreateSetting('script.settingname',default)

" proposed values  (need your help and opinion here)
" * if your script needs some permanent memory 
"   (eg vl#dev#vimscript#autoloadprefix#UpdateAutoloadFunctionList )
"   save it somewhere in 
"   vl#lib#vimscript#scriptsettings#Load('permanent_memory',vl#settings#DotvimDir().'permament_memory')
" * your proposals ...

"|func  if setting 'globalname' (eg g:test_var) exists return it else return
"|      default_value
function! vl#lib#vimscript#scriptsettings#GetValueByNameOrDefault(globalname, default_value)
  if exists(a:globalname)
    exec 'return '.a:globalname
  else
    return a:default_value
  endif
endfunction

"|func gets value if var is defined else defines var with result of func
function! vl#lib#vimscript#scriptsettings#GetOrDefine(var, get_var_content)
  if exists(a:var)
    exec 'return '.a:var
  else
    exec 'let '.a:var.' = '.a:get_var_content
    exec 'return '.a:var
  endif
endfunction

"|func gets value if var is defined else defines var with result of func
"|+    advantage over GetOrDefine: The string value get_var_content_str is
"|+    evaluated if needed only thus you can use this to ask the user (eg
"|+    input)
function! vl#lib#vimscript#scriptsettings#GetOrDefineFromString(var, get_var_content_str)
  if exists(a:var)
    exec 'return '.a:var
  else
    exec 'let '.a:var.' = '.a:get_var_content_str
    exec 'return '.a:var
  endif
endfunction

let g:settings_file = vl#lib#vimscript#scriptsettings#GetValueByNameOrDefault('g:settings_file',vl#settings#DotvimDir().'script_settings')

" save setting value with id
" fix me: preserve order ?
function! vl#lib#vimscript#scriptsettings#Save(id, value)
  let f = filter(vl#lib#files#filefunctions#ReadFile(g:settings_file,[]),"v:val !~ '^".a:id.":'")
  call add(f,a:id.':'.string(a:value))
  call vl#lib#files#filefunctions#WriteFile(f, g:settings_file)
endfunction

function! vl#lib#vimscript#scriptsettings#Load(id, default)
  let f = filter(vl#lib#files#filefunctions#ReadFile(g:settings_file,[]),"v:val =~ '^".a:id.":'")
  if len(f) == 0
    return a:default
  else
    return eval(substitute(f[0],'^'.a:id.':','',''))
  endif
endfunction

" some helper functions

" add String to Stringlist if it hasn't been added yet
function! vl#lib#vimscript#scriptsettings#AddValueToListUnique(id, value)
  call vl#lib#vimscript#scriptsettings#AlterSetting(a:id, [], 
	\ "call vl#lib#listdict#list#AddUnique(value,".string(a:value).")")
endfunction
" remove a value from a list
function! vl#lib#vimscript#scriptsettings#RemoveValueFromList(id, value)
  call vl#lib#vimscript#scriptsettings#AlterSetting(a:id, [], 
	\ 'call filter(value,"v:val!='.string(a:value).'")')
endfunction

" use this function to alter a value using command cmd. the value can be
" accessed by value. If you need an example have a look at 
" function! vl#lib#tags#taghelper#AddTagProfile(profile_name, cmd)
function! vl#lib#vimscript#scriptsettings#AlterSetting(id, default, cmd)
  let value = vl#lib#vimscript#scriptsettings#Load(a:id ,a:default)
  exec a:cmd
  call vl#lib#vimscript#scriptsettings#Save(a:id, value)
endfunction

" caption will be shown above the list
" cmd_nothing_selected will get executed if user selects nothing (thus you can
" return a value or raise an exception or ..0)
function! vl#lib#vimscript#scriptsettings#LetUserChoseKeyFromDict(caption, id, default, cmd_nothing_selected )
  let dict = vl#lib#vimscript#scriptsettings#Load(a:id, a:default)
  let [index, key] = vl#ui#userSelection#LetUserSelectOneOf(a:caption, keys(dict), "return both")
  if index == -1 
    exec a:cmd_nothing_selected
  else
    return key
  endif
endfunction

function! vl#lib#vimscript#scriptsettings#MergeGlobBList(name)
  let result = []
  let g = vl#lib#vimscript#scriptsettings#GetValueByNameOrDefault('g:'.a:name,[])
  let b = vl#lib#vimscript#scriptsettings#GetValueByNameOrDefault('b:'.a:name,[])
  return g+b
endfunction

" snd argument is value to set to
" if it doesn't exist can't be nested
function! vl#lib#vimscript#scriptsettings#StoreSetting(setting_as_string, ...)
  if exists(a:setting_as_string)
    let dict = vl#lib#vimscript#scriptsettings#GetOrDefine('g:stored_settings',{})
    let val = vl#lib#listdict#dict#KeyValue(dict, a:setting_as_string, [])
    let dict[a:setting_as_string] = val " in case it didn't exst reassign
    " prepend setting (push on stack)
    exec 'call add(val,'.a:setting_as_string.')'
  endif
  if a:0 > 0
    if exists(a:setting_as_string)
      unlet a:setting_as_string
    endif
    exec 'let '.a:setting_as_string.' = a:1'
  endif
endfunction

function! vl#lib#vimscript#scriptsettings#RestoreSetting(setting_as_string)
  " TODO: remove empty lists from g:stored_settings
  let dict = vl#lib#vimscript#scriptsettings#GetOrDefine('g:stored_settings','{}')
  let val = vl#lib#listdict#dict#KeyValue(dict, a:setting_as_string, [])
  " prevent type mismatch value"
  if exists(a:setting_as_string)
    exec 'unlet '.a:setting_as_string
  endif
  if len(val)>0
    let last = len(val) -1
    " we assume wasn't set when storing
    exec 'let '.a:setting_as_string.' = remove(val,last)'
  endif
endfunction

""| joins items from g:template_vars and b:template_vars to be used as initial
""| variable dictionary in your own template providing functions (see ...#GetTemplate)
"function vl#lib#vimscript#scriptsettings#GetGOrBVar()
"let vars = vl#lib#vimscript#scriptsettings#GetValueOrDefault('b:template_vars', {})
"call extend(vars, vl#lib#vimscript#scriptsettings#GetValueOrDefault('g:template_vars', {})
"return vars
"endfunction

