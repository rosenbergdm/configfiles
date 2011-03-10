"|fld   description : Provide some templating support.
"|fld   keywords : <+ this is used to index / group scripts ?+> 
"|fld   initial author : Marc Weber marco-oweber@gmx.de
"|fld   mantainer : author
"|fld   started on : 2006 Nov 06 18:41:17
"|fld   version: 0.0
"|fld   dependencies: <+ vim-python, vim-perl, unix-tool sed, ... +>
"|fld   contributors : <+credits to+>
"|fld   tested on os : <+credits to+>
"|fld   maturity: directory templates not yet tested, experimental
"|fld     os: <+ remove this value if script is os independent +>
"|
"|H1__  Documentation
"|
"|p     Some ideas are stolen from vimplate written by Urs Stotz except this
"|+     uses vimscript only ;)
"|
"|H2__  settings
"|set   template handlers. default is the list seen in the next code snippet.
"|      the DirectoryHandler globs a directory for template files and adds them ( call 
"|+     function AddTemplatesFromDirectory to add a directory).
"|      the TemplateHandler just returns the template having been added by call AddTemplate
"|code  let s:templateHandlers=vl#lib#vimscript#scriptsettings#Load('vl.lib.template.template.template_handlers', 
"|      \ [function('vl#lib#template#template_handlers#TemplateGivenDirectlyHandler'), function('vl#lib#template#template_handlers#DirectoryTemplateHandler')])
"|      It should be easy to add your own temlate handlers.
"|      This is an additional function returning a regular expression matching
"|+     ids by CamelCase. Thus you can match MyHeader by MH
"|code  let s:quick_match_expr = vl#lib#vimscript#scriptsettings#Load('dev.vimscript.function_quick_match',
"|         \ function('vl#lib#completion#quick_match_functions#AdvancedCamelCaseMatching'))
"|
"|H2    template handler
"|p     a template handler takes an item which has been added to b:vl_templates
"|+     and returns [0, "wrong handler"] if the list entry wasn't meant for
"|      this handler [1, <list of templates> ]. template entry is a
"|      dictionary:
"|code  { 'id' : <name of this template>
"|    \ , 'value' : arg_to_next_func
"|    \ , 'get_template' : <function taking value returning text to be inserted>
"|    \ }
"|p     The  function get_template must return
"|code       { 'text' : <text to be inserted> }
"|         \ , 'post execute' : <vim script text to be executed using exec> }
"|p     where the entry 'post execute' is optional. If some text is selected
"|+     will be surrounded.
"|p     The cursor will be placed at the beginning of the inserted template.
"|p     You can use "text inserted<++>" and 'post execute' : 'normal <c-j>' to
"|+     set the cursor at the end or somewhere else. ! post execute is not yet
"|+     used and not yet implemented.
"|
"|H2_   Preprocessor
"|p     The template is run through the Preprocessor, which replaces all
"|+     occurrences of [% = code %] with the result of code. code is a vimscript snippet
"|p     Example:      
"|code  Example template having 3 lines
"|      Today is [% = strftime("%Y %b %d %X") %]
"|      end
"|p     You can use a value more than once this way:
"|code  Example template having 3 lines
"|      Today is [% let vars['today'] = strftime("%Y %b %d %X") %][% = vars['today'] %]
"|      and today again [% = vars['today'] %]
"|p     you can use b:template_vars and g:template_vars to provide some
"|      default values which will be added to vars automatically
"|p     There are two special vars [% = cursor %] and [% = selection %].
"|      '= cursor' is used to set a cursor mark which defaults to <++> and 
"|+     '= selection' where the selected text will be inserted.
"|p     Special functions: (to be implemented )
"|      AskUser("vars['dummy']", [default [, completion]]) 
"|      will ask the user for a value to enter and save it to vars['dummy'] if
"|+     the value hasn't been specified yet
"|p     I hope this lets you do all you need. ( Inserting filenames,
"|      conditional text using if cond | text | else  | ..
"|H2_   Interface
"|p     call this function
"|code  call vl#lib#template#template#AddTemplateUI('dir containing template files','another dir')
"|p     to add the commands TemplateShowAvailibleIds, TemplateNew,
"|      TemplateInsert and the mapping <c-s-t>
"|p     So you can type te<c-s-t> to insert a template beeing called test.
"|H2_   One complete working example:
"|code  call vl#lib#template#template#AddTemplate('hello','bc')
"|      call vl#lib#template#template#AddTemplate('files_in_current_directory','[% = string(glob("*")) %]')
"|      call vl#lib#template#template#AddTemplate('today',"Today is \n[% let vars['today'] = strftime('%Y %b %d %X') %][% = vars['today'] %]")
"|      call vl#lib#template#template#AddTemplateUI(vl#settings#DotvimDir().'templates/'.&ft)
"|
"|TODO:  Do much more testing
"|       implement escaping of [% and proper parsing of [% %]
"|       add edit template function
"|+      
"|+      
"|+      
"|rm roadmap (what to do, where to go?)

" this is used to complete templates
let s:quick_match_expr = vl#lib#vimscript#scriptsettings#Load('dev.vimscript.function_quick_match',
   \ vl#dev#vimscript#vimfile#Function('vl#lib#completion#quick_match_functions#AdvancedCamelCaseMatching'))
" cursor mark is inserted when [% = cursor %] is used
let s:cursor_mark = vl#lib#vimscript#scriptsettings#Load('dev.vimscript.function_quick_match',
  \ '<++>')

"|func  adds the directory to template list
"|      the directory content is read when templates are requested
function! vl#lib#template#template#AddTemplatesFromDirectory(directory)
  call vl#lib#brief#conditional#If(!exists('b:vl_templates'), 'let b:vl_templates = []')
  call vl#lib#listdict#list#AddUnique(b:vl_templates, { 'directory': a:directory } )
endfunction

"|func   adds another template which can be requested using id
function! vl#lib#template#template#AddTemplate(id, text)
  call vl#lib#brief#conditional#If(!exists('b:vl_templates'), 'let b:vl_templates = []')
  call vl#lib#listdict#list#AddUnique(b:vl_templates, {'template': { 'id' : a:id, 'text' : a:text } } )
endfunction

"|func   lets the user add a template to a directory selected from
"|+      b:vl_templates
function! vl#lib#template#template#TemplateNew()
  let no_dirs_specified_message = "call vl#lib#template#template#AddTemplatesFromDirectory('<dir>') from within a ftplugin file to specify directories conaining templates first"
  if !exists('b:vl_templates')
    echo no_dirs_specified_message
  else
    let ft = &ft
    let directory_entries = filter(deepcopy(b:vl_templates), 'type(v:val)==4 && vl#lib#listdict#dict#HasKey(v:val,"directory")')
    if len(directory_entries) == 0
      echo no_dirs_specified_message
    else
      let directories = map(directory_entries, 'v:val["directory"]')
      let directory = vl#ui#userSelection#LetUserSelectIfThereIsAChoice('Add template to which directory?', directories)
      echo "remeber that you can use subdirectories, too"
      echo "use [% = selection %] to insert selected text. (te be implemented)"
      echo "    [% let vars['foo'] = <vimscript expession> %] to set a variable"
      echo "    [% = vars['foo'] %] to insert it "
      let file = input('template file: ', vl#lib#files#filefunctions#AddTrailingDelimiter(directory),'file')
      if file == ''
	echo "user aborted"
      else
	exec 'sp '.file
	if &ft == ''
	  let &ft = ft " set filetype to the same filetype
	endif
      endif
    endif
  endif
  return ""
endfunction

"|func   lets the user edit a template from a directory selected from
"|+      b:vl_templates
"|       TODO : this can be made better! redundancy see TemplateNew
function! vl#lib#template#template#TemplateEdit()
  let no_dirs_specified_message = "call vl#lib#template#template#AddTemplatesFromDirectory('<dir>') from within a ftplugin file to specify directories conaining templates first"
  if !exists('b:vl_templates')
    echo no_dirs_specified_message
  else
    let ft = &ft
    let directory_entries = filter(deepcopy(b:vl_templates), 'type(v:val)==4 && vl#lib#listdict#dict#HasKey(v:val,"directory")')
    if len(directory_entries) == 0
      echo no_dirs_specified_message
    else
      let directories = map(directory_entries, 'v:val["directory"]')
      let directory = vl#ui#userSelection#LetUserSelectIfThereIsAChoice('Add template to which directory?', directories)
      let file = input('template file: ', vl#lib#files#filefunctions#AddTrailingDelimiter(directory),'file')
      " change also TemplateNew
      if file == ''
	echo "user aborted"
      else
	exec 'sp '.file
	if &ft == ''
	  let &ft = ft " set filetype to the same filetype
	endif
      endif
    endif
  endif
  return ""
endfunction


"| returns a list of all templates
function! vl#lib#template#template#TemplateList()
  let result = []
  for entry in b:vl_templates 
    let [success, template_list] = vl#lib#brief#handler#Handle(entry, s:templateHandlers)
    if !success
      echoe "wasn't able to handle template entry ".string(entry)
    else
      call extend(result, template_list)
    endif
  endfor
  return result
endfunction

function! vl#lib#template#template#TemplateIdList()
  return map(vl#lib#template#template#TemplateList()
	  \ , "v:val['id']")
endfunction

"| preprocesses the text.
"| This means you can assign variables using [% foo=<some term>%] and use them
"| this way [% = vars['foo'] %]
"| optional argument specifies selected text which replaces [% = selection %] (TODO)
function! vl#lib#template#template#PreprocessTemplatetext(text, vars, ...)
  exec vl#lib#brief#args#GetOptionalArg('selection',string('no optional arg given'))
  let cursor = s:cursor_mark
  "let AskUser = function('vl#lib#template#template#AskUser')

  let vars = deepcopy(a:vars)
  let result = ""
  let parts = split(a:text, '\zs\ze\[%')
  for part in parts
    if part =~ '\[%.*%]'
      let subparts = split(part, '%\]\zs\ze')
      if len(subparts) > 2
	echoe "missing \[%"
      endif
      call add(subparts, '') " add empty string in case of '[% ... %]' without trailing text which will be added
      let vim_script_command = matchstr(subparts[0], '\[%\s*\zs.*\s*\ze%\]$')
      if vim_script_command =~ '^='
	let term = matchstr( vim_script_command, '=\s*\zs.*\ze\s*$')
	exec 'let text = '.term
	let result .= text.subparts[1]
      else
	if vim_script_command  =~ '^\s*let\s\+vars\[' || vim_script_command =~ '^set \%(no\)\=paste'
	  " this term should be something like this: 
	  exec vim_script_command
	else
	  echoe "wrong assignment found: '".vim_script_command."'. Should be something like 'let vars[\"today\"] = ime(\"%Y %b %d %X\")! I do note execute this statement."
	endif
	let result .= subparts[1]
      endif
    else
      let result .= part
    endif
  endfor
  return [result, vars]
endfunction

function! vl#lib#template#template#GetTemplateById(id, ...)
  exec vl#lib#brief#args#GetOptionalArg('vars', string({}))
  let result = []
  for entry in b:vl_templates 
    let [success, template_list] = vl#lib#brief#handler#Handle(entry, s:templateHandlers)
    if !success
      echoe "wasn't able to handle template entry ".string(entry)
    else
      for entry in template_list
	if entry['id'] == a:id
	  let F = entry['get_template']
	  return F(entry['value'],vars)
	endif
      endfor
    endif
  endfor
  echoe "template with id '".a:id."' not found"
endfunction

function! vl#lib#template#template#TemplateTextById(id, ...)
  exec vl#lib#brief#args#GetOptionalArg('vars', string({}))
  let template = vl#lib#template#template#GetTemplateById(a:id, vars)
  return template['text']
endfunction

function! vl#lib#template#template#InsertTemplate(id,...)
  exec vl#lib#brief#args#GetOptionalArg('vars', string({}))
  let cursor_saved = getpos(".")
  let text_to_insert = vl#lib#template#template#TemplateTextById(a:id,vars)
  let @" = text_to_insert
  if len(text_to_insert) == 0
    echoe "strange. template resulted in empty string"
  endif
  exec "normal a\<c-r>\""
  call cursor(cursor_saved)
endfunction

function! vl#lib#template#template#CompleteTemplateId(ArgLead,L,P)
  let ids = vl#lib#template#template#TemplateIdList()
  let matching_ids= filter(deepcopy(ids), 
     \ "v:val =~".string(s:quick_match_expr(a:ArgLead)))
  call extend(matching_ids, filter(ids, "v:val =~".string(a:ArgLead)))
  let matching_ids = vl#lib#listdict#list#Unique(matching_ids)
  return join(matching_ids,"\n")
endfunction

"|func this function can be used to be able to use omni completion
function! vl#lib#template#template#CompleteTemplate(findstart, base)
  if a:findstart
    " locate the start of the word
    let [bc,ac] = vl#lib#buffer#splitlineatcursor#SplitCurrentLineAtCursor()
    return len(bc)-len(matchstr(bc,'\%(\a\|\.\|\$\|\^\)*$'))
  else
    let ids = vl#lib#template#template#TemplateList()
    let matching_ids= filter(deepcopy(ids), 
       \ "v:val['id'] =~".string(s:quick_match_expr(a:base)))
    call extend(matching_ids, filter(ids, "v:val['id'] =~".string(a:base)))
    " let matching_ids = vl#lib#listdict#list#Unique(matching_ids)
    echo len(matching_ids).' tepmlates found. choose on from list'
    " unfortunately we have to add the text to be inserted right now..
    for entry in matching_ids
      if complete_check()
	return []
      endif
      let F = entry['get_template']
      let template =   F(entry['value'])
      let text_to_insert = template['text']
      call complete_add( { 'word' : substitute(text_to_insert,"\n","\r",'g')
		       \ , 'abbr' : entry['id']
		       \ } )
		       "\ , 'menu': text_to_insert

    endfor
  endif
endfunction

"|func reads the last words before cursor and lets user choose an matching
"|     template id from list. See example mapping
"|     this also restores the paste option. This way you can use [%set paste%]
"|+    in your template
function! vl#lib#template#template#TemplateFromBufferWord()
  let paste = &paste
  let [b, a] = vl#lib#buffer#splitlineatcursor#SplitCurrentLineAtCursor()
  let word = matchstr(b,'\w*$')
  let ids = split(vl#lib#template#template#CompleteTemplateId(word,0,0),"\n")
  let id = vl#ui#userSelection#LetUserSelectIfThereIsAChoice("which template?", ids)
  if id == ""
    return 
  endif
  let text = repeat("\<bs>",len(word)).vl#lib#template#template#TemplateTextById(id)
  return text."\<c-o>:set ".(paste ? "" : "no")."paste\<cr>"
endfunction

"| adds template commands
"| optional arguments are diretories to add templates form
function! vl#lib#template#template#AddTemplateUI(...)
  " gets a list of directories from b:vl_templates and lets the user choose one
  " of them to add a new template
  command! TemplateNew :call vl#lib#template#template#TemplateNew()<cr>
  " gets a list of directories from b:vl_templates and lets the user choose one
  " of them to edit a template
  command! TemplateEdit :call vl#lib#template#template#TemplateEdit()<cr>
  command! -buffer -nargs=1 -complete=custom,vl#lib#template#template#CompleteTemplateId TemplateInsert  :call vl#lib#template#template#InsertTemplate(<f-args>)
  command! -buffer TemplateShowAvailibleIds :echo join(map(vl#lib#template#template#TemplateList(),"v:val['id']"),"\n")
  " inoremap <m-t> <c-r>=vl#lib#template#template#TemplateTextById(input("template id :",'',"custom,vl#lib#template#template#CompleteTemplateId"))<cr>
  inoremap <m-s-t> <c-r>=vl#lib#template#template#TemplateFromBufferWord()<cr>
 " <c-o>:redraw<cr>
  call vl#lib#brief#map#MapCommand(a:000,'call vl#lib#template#template#AddTemplatesFromDirectory(val)')
endfunction

"| joins items from g:template_vars and b:template_vars to be used as initial
"| variable dictionary in your own template providing functions (see ...#GetTemplate)
function! vl#lib#template#template#GetVars()
  let vars = deepcopy(vl#lib#vimscript#scriptsettings#GetValueByNameOrDefault('b:template_vars', {}))
  call extend(vars, vl#lib#vimscript#scriptsettings#GetValueByNameOrDefault('g:template_vars', {}))
  return vars
endfunction


"func arg list: list of [ "file", "template" ] to create
"     optional arg is default values
function! vl#lib#template#template#CreateFilesFromTemplates(list,...)
  exec vl#lib#brief#args#GetOptionalArg('vars',string([]))
  for [file, template] in a:list
    exec 'sp '.file
    " remove everything which might have been written by filetype templates
    normal ggdG
    let template_text = vl#lib#template#template#GetTemplateById(template, vars)
    call vl#lib#template#template#InsertTemplate(template, vars)
  endfor
endfunction

" ------------------------
" template handler where template text is given directly
function! vl#lib#template#template#GetTemplate( template_text, ...)
  exec vl#lib#brief#args#GetOptionalArg('vars', string({}))
  let [ text, vars ] = vl#lib#template#template#PreprocessTemplatetext( a:template_text 
	\ ,  vars )
  return { 'text' : text }
endfunction


" handles template given directly
function! vl#lib#template#template#TemplateGivenDirectlyHandler(template)
  if type(a:template) == 4 && vl#lib#listdict#dict#HasKey(a:template, 'template')
    let template = a:template['template']
    return [1, [{ 'id' : template['id']
	      \ , 'value' : template['text']
	      \ , 'get_template' : function('vl#lib#template#template#GetTemplate')
	      \ }] ]
  else
    return [0, "wrong handler"]
  endif
endfunction

" ------------------------
" directory template handler
function! vl#lib#template#template#GetDirectoryTemplate(path, ...)
  exec vl#lib#brief#args#GetOptionalArg('vars', string({}))
  let text = join(vl#lib#files#filefunctions#ReadFile(expand(a:path), ['strange error, template file '.a:path .' file not found'])
		\ , "\n")
  let [ text2, vars ] = vl#lib#template#template#PreprocessTemplatetext( text
	\ , vars)
  return { 'text' : text2 }
endfunction

function! vl#lib#template#template#DirectoryTemplateHandler( template )
  if type(a:template) == 4 && vl#lib#listdict#dict#HasKey(a:template, 'directory')
    let directory = a:template['directory']
    let template_files = split(globpath(expand(directory),'**/*'),"\n")
    call filter(template_files, 'filereadable(v:val)') " no directories!
    let templates = []
    for file in template_files
      call add(templates, { 'id' : matchstr(file, '^\%('.vl#lib#conversion#string#QuoteBackslashSpecial(expand(directory)).'\)\=[/\\]\=\zs.*\ze')
			\ , 'value' : file
			\ , 'get_template' : function('vl#lib#template#template#GetDirectoryTemplate')
			\ })
    endfor
    return [1, templates]
  else
    return [0, "wrong handler"]
  endif
endfunction

let s:templateHandlers=vl#lib#vimscript#scriptsettings#Load(
    \ 'vl.lib.template.template.template_handlers'
    \ , [ function('vl#lib#template#template#TemplateGivenDirectlyHandler')
    \   , function('vl#lib#template#template#DirectoryTemplateHandler')
    \   ] )
