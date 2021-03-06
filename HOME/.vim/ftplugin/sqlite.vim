" SQL filetype plugin file
" Language:    Sqlite
" Version:     3
" Maintainer:  David M. Rosenberg
" Last Change: Mon May 03 12:00 PM 2010 C
" Download:    

" All files called sqlinformix.vim will be loaded from the indent and syntax
" directories.  This allows you to easily flip SQL dialects on a per file
" basis.  NOTE: you can also use completion:
"     :SQLSetType <tab>
"
" To change the default dialect, add the following to your vimrc:
"    let g:sql_type_default = 'sqlanywhere'


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

let s:save_cpo = &cpo
set cpo=

" Disable autowrapping for code, but enable for comments
" t	Auto-wrap text using textwidth
" c     Auto-wrap comments using textwidth, inserting the current comment
"       leader automatically.
setlocal formatoptions-=t
setlocal formatoptions-=c

" Functions/Commands to allow the user to change SQL syntax dialects
" through the use of :SQLSetType <tab> for completion.
" This works with both Vim 6 and 7.

if !exists("*SQL_SetType")
    " NOTE: You cannot use function! since this file can be 
    " sourced from within this function.  That will result in
    " an error reported by Vim.
    function SQL_GetList(ArgLead, CmdLine, CursorPos)

        if !exists('s:sql_list')
            " Grab a list of files that contain "sql" in their names
            let list_indent   = globpath(&runtimepath, 'indent/*sql*')
            let list_syntax   = globpath(&runtimepath, 'syntax/*sql*')
            let list_ftplugin = globpath(&runtimepath, 'ftplugin/*sql*')

            let sqls = "\n".list_indent."\n".list_syntax."\n".list_ftplugin."\n"

            " Strip out everything (path info) but the filename
            " Regex
            "    From between two newline characters
            "    Non-greedily grab all characters
            "    Followed by a valid filename \w\+\.\w\+ (sql.vim)
            "    Followed by a newline, but do not include the newline
            "
            "    Replace it with just the filename (get rid of PATH)
            "
            "    Recursively, since there are many filenames that contain
            "    the word SQL in the indent, syntax and ftplugin directory
            let sqls = substitute( sqls, 
                        \ '[\n]\%(.\{-}\)\(\w\+\.\w\+\)\n\@=', 
                        \ '\1\n', 
                        \ 'g'
                        \ )

            " Remove duplicates, since sqlanywhere.vim can exist in the
            " sytax, indent and ftplugin directory, yet we only want
            " to display the option once
            let index = match(sqls, '.\{-}\ze\n')
            while index > -1
                " Get the first filename
                let file = matchstr(sqls, '.\{-}\ze\n', index)
                " Recursively replace any *other* occurrence of that
                " filename with nothing (ie remove it)
                let sqls = substitute(sqls, '\%>'.(index+strlen(file)).'c\<'.file.'\>\n', '', 'g')
                " Move on to the next filename
                let index = match(sqls, '.\{-}\ze\n', (index+strlen(file)+1))
            endwhile

            " Sort the list if using version 7
            if v:version >= 700
                let mylist = split(sqls, "\n")
                let mylist = sort(mylist)
                let sqls   = join(mylist, "\n")
            endif

            let s:sql_list = sqls
        endif

        return s:sql_list

    endfunction

    function SQL_SetType(name)

        " User has decided to override default SQL scripts and
        " specify a vendor specific version 
        " (ie Oracle, Informix, SQL Anywhere, ...)
        " So check for an remove any settings that prevent the
        " scripts from being executed, and then source the 
        " appropriate Vim scripts.
        if exists("b:did_ftplugin")
            unlet b:did_ftplugin
        endif
        if exists("b:current_syntax")
            " echomsg 'SQLSetType - clearing syntax'
            syntax clear
        endif
        if exists("b:did_indent")
            " echomsg 'SQLSetType - clearing indent'
            unlet b:did_indent
            " Set these values to their defaults
            setlocal indentkeys&
            setlocal indentexpr&
        endif

        " Ensure the name is in the correct format
        let new_sql_type = substitute(a:name, 
                    \ '\s*\([^\.]\+\)\(\.\w\+\)\?', '\L\1', '')

        " Do not specify a buffer local variable if it is 
        " the default value
        if new_sql_type == 'sql'
          let new_sql_type = 'sqloracle'
        endif
        let b:sql_type_override = new_sql_type

        " Vim will automatically source the correct files if we
        " change the filetype.  You cannot do this with setfiletype
        " since that command will only execute if a filetype has
        " not already been set.  In this case we want to override
        " the existing filetype.
        let &filetype = 'sql'
    endfunction
    command! -nargs=* -complete=custom,SQL_GetList SQLSetType :call SQL_SetType(<q-args>)

endif

if exists("b:sql_type_override")
    " echo 'sourcing buffer ftplugin/'.b:sql_type_override.'.vim'
    if globpath(&runtimepath, 'ftplugin/'.b:sql_type_override.'.vim') != ''
        exec 'runtime ftplugin/'.b:sql_type_override.'.vim'
    " else
    "     echomsg 'ftplugin/'.b:sql_type_override.' not exist, using default'
    endif
elseif exists("g:sql_type_default")
    " echo 'sourcing global ftplugin/'.g:sql_type_default.'.vim'
    if globpath(&runtimepath, 'ftplugin/'.g:sql_type_default.'.vim') != ''
        exec 'runtime ftplugin/'.g:sql_type_default.'.vim'
    " else
    "     echomsg 'ftplugin/'.g:sql_type_default.'.vim not exist, using default'
    endif
endif

" If the above runtime command succeeded, do not load the default settings
if exists("b:did_ftplugin")
  finish
endif

let b:undo_ftplugin = "setl comments<"

" Don't load another plugin for this buffer
let b:did_ftplugin     = 1
let b:current_ftplugin = 'sql'

" Win32 can filter files in the browse dialog
if has("gui_win32") && !exists("b:browsefilter")
    let b:browsefilter = "SQL Files (*.sql)\t*.sql\n" .
	  \ "All Files (*.*)\t*.*\n"
endif

" Some standard expressions for use with the matchit strings
let s:notend = '\%(\<end\s\+\)\@<!'
let s:when_no_matched_or_others = '\%(\<when\>\%(\s\+\%(\%(\<not\>\s\+\)\?<matched\>\)\|\<others\>\)\@!\)'
let s:or_replace = '\%(or\s\+replace\s\+\)\?'

" Define patterns for the matchit macro
if !exists("b:match_words")
    " SQL is generally case insensitive
    let b:match_ignorecase = 1

    " Handle the following:
    " if
    " elseif | elsif
    " else [if]
    " end if
    "
    " [while condition] loop
    "     leave
    "     break
    "     continue
    "     exit
    " end loop
    "
    " for
    "     leave
    "     break
    "     continue
    "     exit
    " end loop
    "
    " do
    "     statements
    " doend
    "
    " case
    " when 
    " when
    " default
    " end case
    "
    " merge
    " when not matched
    " when matched
    "
    " EXCEPTION
    " WHEN column_not_found THEN
    " WHEN OTHERS THEN
    "
    " create[ or replace] procedure|function|event

    let b:match_words =
		\ '\<begin\>:\<end\>\W*$,'.
		\
                \ s:notend . '\<if\>:'.
                \ '\<elsif\>\|\<elseif\>\|\<else\>:'.
                \ '\<end\s\+if\>,'.
                \
                \ '\<do\>\|'.
                \ '\<while\>\|'.
                \ '\%(' . s:notend . '\<loop\>\)\|'.
                \ '\%(' . s:notend . '\<for\>\):'.
                \ '\<exit\>\|\<leave\>\|\<break\>\|\<continue\>:'.
                \ '\%(\<end\s\+\%(for\|loop\>\)\)\|\<doend\>,'.
                \
                \ '\%('. s:notend . '\<case\>\):'.
                \ '\%('.s:when_no_matched_or_others.'\):'.
                \ '\%(\<when\s\+others\>\|\<end\s\+case\>\),' .
                \
                \ '\<merge\>:' .
                \ '\<when\s\+not\s\+matched\>:' .
                \ '\<when\s\+matched\>,' .
                \
                \ '\%(\<create\s\+' . s:or_replace . '\)\?'.
                \ '\%(function\|procedure\|event\):'.
                \ '\<returns\?\>'
                " \ '\<begin\>\|\<returns\?\>:'.
                " \ '\<end\>\(;\)\?\s*$'
                " \ '\<exception\>:'.s:when_no_matched_or_others.
                " \ ':\<when\s\+others\>,'.
		"
                " \ '\%(\<exception\>\|\%('. s:notend . '\<case\>\)\):'.
                " \ '\%(\<default\>\|'.s:when_no_matched_or_others.'\):'.
                " \ '\%(\%(\<when\s\+others\>\)\|\<end\s\+case\>\),' .
endif

" Define how to find the macro definition of a variable using the various
" [d, [D, [_CTRL_D and so on features
" Match these values ignoring case
" ie  DECLARE varname INTEGER
let &l:define = '\c\<\(VARIABLE\|DECLARE\|IN\|OUT\|INOUT\)\>'


" Mappings to move to the next BEGIN ... END block
" \W - no characters or digits
nmap <buffer> <silent> ]] :call search('\\c^\\s*begin\\>', 'W' )<CR>
nmap <buffer> <silent> [[ :call search('\\c^\\s*begin\\>', 'bW' )<CR>
nmap <buffer> <silent> ][ :call search('\\c^\\s*end\\W*$', 'W' )<CR>
nmap <buffer> <silent> [] :call search('\\c^\\s*end\\W*$', 'bW' )<CR>
vmap <buffer> <silent> ]] :<C-U>exec "normal! gv"<Bar>call search('\\c^\\s*begin\\>', 'W' )<CR>
vmap <buffer> <silent> [[ :<C-U>exec "normal! gv"<Bar>call search('\\c^\\s*begin\\>', 'bW' )<CR>
vmap <buffer> <silent> ][ :<C-U>exec "normal! gv"<Bar>call search('\\c^\\s*end\\W*$', 'W' )<CR>
vmap <buffer> <silent> [] :<C-U>exec "normal! gv"<Bar>call search('\\c^\\s*end\\W*$', 'bW' )<CR>


" By default only look for CREATE statements, but allow
" the user to override
if !exists('g:ftplugin_sql_statements')
    let g:ftplugin_sql_statements = 'create'
endif

" Predefined SQL objects what are used by the below mappings using
" the ]} style maps.
" This global variable allows the users to override it's value
" from within their vimrc.
" Note, you cannot use \?, since these patterns can be used to search
" backwards, you must use \{,1}
if !exists('g:ftplugin_sql_objects')
    let g:ftplugin_sql_objects = 'function,procedure,event,' .
                \ '\\(existing\\\\|global\\s\\+temporary\\s\\+\\)\\\{,1}' .
                \ 'table,trigger' .
                \ ',schema,service,publication,database,datatype,domain' .
                \ ',index,subscription,synchronization,view,variable'
endif

" Replace all ,'s with bars, except ones with numbers after them.
" This will most likely be a \{,1} string.
let s:ftplugin_sql_objects = 
            \ '\\c^\\s*' .
            \ '\\(\\(' .
            \ substitute(g:ftplugin_sql_statements, ',\d\@!', '\\\\\\|', 'g') .
            \ '\\)\\s\\+\\(or\\s\\+replace\\\s\+\\)\\{,1}\\)\\{,1}' .
            \ '\\<\\(' .
            \ substitute(g:ftplugin_sql_objects, ',\d\@!', '\\\\\\|', 'g') .
            \ '\\)\\>' 

" Mappings to move to the next CREATE ... block
exec "nmap <buffer> <silent> ]} :call search('".s:ftplugin_sql_objects."', 'W')<CR>"
exec "nmap <buffer> <silent> [{ :call search('".s:ftplugin_sql_objects."', 'bW')<CR>"
" Could not figure out how to use a :call search() string in visual mode
" without it ending visual mode
" Unfortunately, this will add a entry to the search history
exec 'vmap <buffer> <silent> ]} /'.s:ftplugin_sql_objects.'<CR>'
exec 'vmap <buffer> <silent> [{ ?'.s:ftplugin_sql_objects.'<CR>'

" Mappings to move to the next COMMENT
"
" Had to double the \ for the \| separator since this has a special
" meaning on maps
let b:comment_leader = '\\(--\\\|\\/\\/\\\|\\*\\\|\\/\\*\\\|\\*\\/\\)'
" Find the start of the next comment
let b:comment_start  = '^\\(\\s*'.b:comment_leader.'.*\\n\\)\\@<!'.
            \ '\\(\\s*'.b:comment_leader.'\\)'
" Find the end of the previous comment
let b:comment_end = '\\(^\\s*'.b:comment_leader.'.*\\n\\)'.
            \ '\\(^\\s*'.b:comment_leader.'\\)\\@!'
" Skip over the comment
let b:comment_jump_over  = "call search('".
            \ '^\\(\\s*'.b:comment_leader.'.*\\n\\)\\@<!'.
            \ "', 'W')"
let b:comment_skip_back  = "call search('".
            \ '^\\(\\s*'.b:comment_leader.'.*\\n\\)\\@<!'.
            \ "', 'bW')"
" Move to the start and end of comments
exec 'nnoremap <silent><buffer> ]" :call search('."'".b:comment_start."'".', "W" )<CR>'
exec 'nnoremap <silent><buffer> [" :call search('."'".b:comment_end."'".', "W" )<CR>'
exec 'vnoremap <silent><buffer> ]" :<C-U>exec "normal! gv"<Bar>call search('."'".b:comment_start."'".', "W" )<CR>'
exec 'vnoremap <silent><buffer> [" :<C-U>exec "normal! gv"<Bar>call search('."'".b:comment_end."'".', "W" )<CR>'

" Comments can be of the form:
"   /*
"    *
"    */
" or
"   --
" or
"   // 
setlocal comments=s1:/*,mb:*,ex:*/,:--,://

" Set completion with CTRL-X CTRL-O to autoloaded function.
if exists('&omnifunc')
    " Since the SQL completion plugin can be used in conjunction
    " with other completion filetypes it must record the previous
    " OMNI function prior to setting up the SQL OMNI function
    let b:sql_compl_savefunc = &omnifunc

    " This is used by the sqlcomplete.vim plugin
    " Source it for it's global functions
    runtime autoload/syntaxcomplete.vim 

    setlocal omnifunc=sqlcomplete#Complete
    " Prevent the intellisense plugin from loading
    let b:sql_vis = 1
    if !exists('g:omni_sql_no_default_maps')
        " Static maps which use populate the completion list
        " using Vim's syntax highlighting rules
        imap <buffer> <c-c>a <C-\><C-O>:call sqlcomplete#Map('syntax')<CR><C-X><C-O>
        imap <buffer> <c-c>k <C-\><C-O>:call sqlcomplete#Map('sqlKeyword')<CR><C-X><C-O>
        imap <buffer> <c-c>f <C-\><C-O>:call sqlcomplete#Map('sqlFunction')<CR><C-X><C-O>
        imap <buffer> <c-c>o <C-\><C-O>:call sqlcomplete#Map('sqlOption')<CR><C-X><C-O>
        imap <buffer> <c-c>T <C-\><C-O>:call sqlcomplete#Map('sqlType')<CR><C-X><C-O>
        imap <buffer> <c-c>s <C-\><C-O>:call sqlcomplete#Map('sqlStatement')<CR><C-X><C-O>
        " Dynamic maps which use populate the completion list
        " using the dbext.vim plugin
        imap <buffer> <c-c>t <C-\><C-O>:call sqlcomplete#Map('table')<CR><C-X><C-O>
        imap <buffer> <c-c>p <C-\><C-O>:call sqlcomplete#Map('procedure')<CR><C-X><C-O>
        imap <buffer> <c-c>v <C-\><C-O>:call sqlcomplete#Map('view')<CR><C-X><C-O>
        imap <buffer> <c-c>c <C-\><C-O>:call sqlcomplete#Map('column')<CR><C-X><C-O>
        imap <buffer> <c-c>l <C-\><C-O>:call sqlcomplete#Map('column_csv')<CR><C-X><C-O>
        " The next 3 maps are only to be used while the completion window is
        " active due to the <CR> at the beginning of the map
        imap <buffer> <c-c>L <C-Y><C-\><C-O>:call sqlcomplete#Map('column_csv')<CR><C-X><C-O>
        " <C-Right> is not recognized on most Unix systems, so only create
        " these additional maps on the Windows platform.
        " If you would like to use these maps, choose a different key and make
        " the same map in your vimrc.
        if has('win32')
            imap <buffer> <c-right>  <C-R>=sqlcomplete#DrillIntoTable()<CR>
            imap <buffer> <c-left>  <C-R>=sqlcomplete#DrillOutOfColumns()<CR>
        endif
        " Remove any cached items useful for schema changes
        imap <buffer> <c-c>R <C-\><C-O>:call sqlcomplete#Map('resetCache')<CR><C-X><C-O>
    endif

    if b:sql_compl_savefunc != ""
        " We are changing the filetype to SQL from some other filetype
        " which had OMNI completion defined.  We need to activate the
        " SQL completion plugin in order to cache some of the syntax items
        " while the syntax rules for SQL are active.
        call sqlcomplete#PreCacheSyntax()
    endif
endif

let &cpo = s:save_cpo

" vim:sw=4:

