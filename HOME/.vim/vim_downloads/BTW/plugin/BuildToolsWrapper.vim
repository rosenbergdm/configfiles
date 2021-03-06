"=============================================================================
" $Id: BuildToolsWrapper.vim 129 2008-10-28 01:37:36Z luc.hermitte $
" File:		BuildToolsWrapper.vim         {{{1
" Maintainer:	Luc Hermitte <MAIL:hermitte {at} free {dot} fr>
" 		<URL:http://hermitte.free.fr/vim/>
" Last Update:	06th Nov 2007
" Version:	0.0.10
" Created:	28th Nov 2004
"------------------------------------------------------------------------
" Description:	Flexible alternative to Vim compiler-plugins.
"
"------------------------------------------------------------------------
" GetLatestVimScripts: �script_id� �src_id� :AutoInstall: BuildToolsWrapper
" Installation:
"	Drop this plugin into {rtp}/plugin/
"	Requires: lh-vim-lib, also available on my web site
"	Other Recommended Scripts: menu-maps.vim, local_vimrc.vim
"
" History:                               {{{2
"  v0.0.1: 28th Nov 2004 : First Version
"  	* Focalize on :BTW
"
"  v0.0.2: Merge two related projects.
"	* Integrate the work I've done on the previous C-ftplugin ->
"	  c_compile.vim
"
"  v0.0.3:
"	* �:Make� support an optional list of targets
"	* BTW_filter_prog can be local to a buffer
"	  => regarding to the current directory (thanks to local_vimrc.vim) we
"	  can use different makefiles, but the same build program.
"	  The other solution I haven't considered (yet?) was to use callback
"	  functions.
"	* Little bug fix in the ``edit settings'' confirm-box ; some \n were
"	  badly handled.
"	* New commands: :Copen and :Cwindow which work like :copen and :cwindow
"	  except they show up to BTW_QF_size error lines (default 15), and they
"	  jump (or not) to the first error according to BTW_GotoError.
"
"  v0.0.4: 13th Jan 2005
"	* g:BTW_qf_position -> :vert, :lefta, :abo, ...
"	* �:BTW reloadPlugin� -> To ease plugin test & maintenance
"
"  v0.0.5: 11th Mar 2005
"	* �:BTW delete�
"	* �:BTW echo� auto completes the values of various internal functions
"	  ProjectName() TargetRule() Executable()
"
"  v0.0.6: 26th May 2005
"  	* Do not prepend './' to executable path if, under unix, it starts with
"  	  '/'
"
"  v0.0.7: 27th May 2005
"  	* Use :cclose instead of :bw in s:CompileQF()
"  	* Use :cclose as well in s:Executable(), s:ProjectName() and
"  	  s:TargetRule()
"  	* No need to quote the arguments to :Make anymore
"  	* Can run :Make in background, if the option
"  	  [bg]:BTW_make_in_background is set to 1
"  	  Warning: As those damn pop-ups on the Internet, the quickfix window
"  	  can be opened at any time. Which may break our current manipulations.
"  	* Toggled menu for g:BTW_make_in_background (g(lobal) scope only, not [bg])
"
"  v0.0.8: 30th May 2005
"  	* new option for errorformat configuration: g:BTW_ignore_efm_{filter}
"  	* We can ask for using the default value of efm by setting
"  	  g:BTW_adjust_efm_{filter} to "default efm".
"         Default efm: -> �set efm&vim�
"             %f(%l) : %t%*\D%n: %m
"             %*[^"]"%f"%*\D%l: %m
"             %f(%l) : %m
"             %*[^ ] %f %l: %m
"             %f:%l:%m
"
"  v0.0.9: 22nd Jul 2005
"  	* Run in background works with several filters (output piped), and even
"  	  with filter that expands into "cd path ; make -f file.mk"
"  	  Tested under Solaris.
"  	* The temporary file can be in any directory.
"
"  v0.0.10: 17th Nov 2005 - 06th Nov 2007
"  	* First support for syntax additions -> [bg]BTW_qf_syntax_{...}
"  	  Will be rewritten ...
"  	* Better management of efm
"  	* Simplification: Use of :cgetfile for build in backgound
"	* Auto detection of where run_in_background.pl is, without the explicit
"	  need to searchInRuntime.vim -- as long as Vim supports the function
"	  |globpath()|
"	* auto-import of |compiler-plugin| with just "|BTW-add| ant" for
"	  instance.
"	* A filter can import definitions from a |compiler-plugin|. e.g.:
"	     let g:BTW_adjust_efm_{filter} = 'import: ant,default efm' 
"	  If the filter does not provide a [bg]:BTW_filter_program_{filter},
"	  the one from the compiler plugin will be used.
"	* Executable() programs (in $PATH) can be added as filter
"	* Adapted to the refactorization of MenuMake
"	* run_in_background patched to work under Cygwin -- except perl's fork
"	  isn't forking
"	* b:want_buffermenu_or_global_disable is not used as the menus are not
"	  limited to the current buffer
"	* Dependency changed from LHOption to lh-vim-lib
"
"
" TODO:                                  {{{2
"	* &magic
"	* Support priority -> �:BTW add cygwin 9�
"	* Write doc
"	* � addlocal when there is already something ?
"	  - or, xor,
"	  - use local only ?
"       * Folding -> tools names (ld, gcc, g++) + other tools
"         1st lvl: directories
"         2nd lvl: tools <--- use special colors for tools
"         3rd lvl: files
"       * Test if the definition abort (reconstruct). If so, revert to the
"         preceding values of the variables. (-> try-finally ?)
"       * Some way to use the efm values from another filter (we may consider
"         that loading the filter is enough), or directly set:
"             let g:BTW_adjust_efm_foo = g:BTW_adjust_efm_bar
"       * if '$*' is already present in the filter_program, then don't append
"	  it.
"	* Test run_in_background.pl with VimDetect.pm
"	* Is there a real need for �:LMake�, �:LOpen� ? I'm not sure that
"	  commands like :lmake (et al.) are that useful as long as there is no
"	  way  to say that a particular |location-list| is shared between
"	  several windows from a same project.
"	* executable() filters should be able to accept arguments
" }}}1
"=============================================================================


"=============================================================================
" Avoid global reinclusion             {{{1
let s:cpo_save=&cpo
set cpo&vim

if exists("g:loaded_BuildToolsWrapper")
      \ && !exists('g:force_reload_BuildToolsWrapper')
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_BuildToolsWrapper = 1

" Dependancies                         {{{1

" Checks:                                {{{2
if !exists('*lh#option#Get')
  runtime autoload/lh/option.vim
endif
if !exists('*lh#option#Get')
  call lh#common#ErrorMsg( "Build Tools Wrapper:\n  This plugin requires the VimL library lh-vim-lib.\n"
	\."  Check on <http://hermitte.free.fr/vim/>")
  finish
endif
" Dependencies }}}1
" Options                              {{{1
let s:key_make    = lh#option#Get('BTW_key_make'   , '<F7>')
let s:key_execute = lh#option#Get('BTW_key_execute', '<C-F5>')
let s:key_config  = lh#option#Get('BTW_key_config' , '<M-F7>')

if exists('s:run_in_background')
    unlet s:run_in_background
endif

function! s:FetchRunInBackground()
  let rib_progname = lh#system#OnDOSWindows()
	\ ? 'run_and_recontact_vim'
	\ : 'run_in_background'

  if     exists('*globpath')
    let s:run_in_background = globpath(&rtp, 'compiler/BTW/'.rib_progname.'.pl')
  elseif exists(':SearchInRuntime')
    SearchInRuntime let\ s:run_in_background=" compiler/BTW/".rib_progname.".pl | "
  else
    call lh#common#ErrorMsg( "Build Tools Wrapper:\n  This plugin requires either a version of Vim that defines |globpath()| or the script searchInRuntime.vim.\n"
	  \."  Please upgrade your version of vim, or install searchInRuntime.vim\n"
	  \."  Check on <http://hermitte.free.fr/vim/> or <http://vim.sf.net/> script #229")
    finish
  endif

  let s:run_in_background = 'perl '.lh#system#FixPathName(s:run_in_background, !lh#system#OnDOSWindows())
endfunction

function! s:RunInBackground()
  if !exists('s:run_in_background')
    call s:FetchRunInBackground()
  endif
  return s:run_in_background
endfunction

" Options }}}1
"------------------------------------------------------------------------
" Commands and mappings                {{{1

" Multi-purposes command                 {{{2
command! -nargs=+ -complete=custom,BTWComplete BTW :call s:BTW(<f-args>)

" Build/Make invokation                  {{{2
command! -nargs=* Make			:call <sid>Compile("<args>")
command! -nargs=0 Execute		:call <sid>Execute()
command! -nargs=0 AddLetModeline	:call <sid>AddLetModeline()
command! -nargs=0 Copen			:call <sid>ShowError('copen')
command! -nargs=0 Cwindow		:call <sid>ShowError('cwindow')
command! -nargs=+ CopenBG		:call <sid>CopenBG(<f-args>)
command! -nargs=0 ToggleMakeBG		:call <sid>ToggleMakeInBG()

" Menus                                  {{{2

function! s:MenuMakeBG()
  if has('gui_running') && has ('menu')
    let value = lh#option#Get('BTW_make_in_background', 0, 'g')
    amenu 50.99 &Project.---<sep>--- Nop
    let C  = value ? 'X' : "\\ "
    let UC = value ? "\\ " : 'X'
    silent! exe "anoremenu 50.100 &Project.&[" . C . escape("] Make in &background", '\ ') . " :ToggleMakeBG<cr>"
    silent! exe "aunmenu Project.[" . UC . escape ("] Make in background", ' ')
  endif
endfunction

if has('gui_running') && has ('menu')
      \ && 0!=strlen(globpath(&rtp, 'autoload/lh/menu.vim'))
    " let b:want_buffermenu_or_global_disable = 0
    " 0->no ; 1->yes ; 2->global disable
  call lh#menu#Make('n', '50.10', '&Project.&Config', s:key_config,
	  \ '', ':AddLetModeline<cr>')
    amenu 50.10 &Project.--<sep>-- Nop
  call lh#menu#Make('ni', '50.30', '&Project.&Make project', s:key_make,
	  \ '', ':Make<cr>')
  call lh#menu#Make('ni', '50.50', '&Project.&Execute', s:key_execute,
	  \ '', ':Execute<cr>')

    call s:MenuMakeBG()
else
  exe '  nnoremap '.s:key_make   .':call <sid>Compile()<cr>'
  exe '  inoremap '.s:key_make   .'<c-o>:call <sid>Compile()<cr>'

  exe '  nnoremap '.s:key_execute.':call <sid>Execute()<cr>'
  exe '  inoremap '.s:key_execute.'<c-o>:call <sid>Execute()<cr>'

  exe '  nnoremap '.s:key_config .': call <sid>AddLetModeline()<cr>'
endif
" Commands and mappings }}}1
"------------------------------------------------------------------------
" Internals                            {{{1

let s:sfile = expand('<sfile>:p')

" Build Chain:                           {{{2

" Constants {{{3
let s:commands="set\nsetlocal\nadd\naddlocal\nremove\nremovelocal\nrebuild\necho\nreloadPlugin\n?\nhelp"
let s:functions="ToolsChain()\nHasFilterGuessScope(\nHasFilter(\nFindFilter("
let s:functions=s:functions. "\nProjectName()\nTargetRule()\nExecutable()"
let s:variables="commands\nfunctions\nvariables"


" ToVarName(filterName):                         {{{3
function! s:ToVarName(filterName)
  let filterName = substitute(a:filterName, '[^A-Za-z0-9_]', '_', 'g')
  return filterName
endfunction

" BTWComplete(ArgLead, CmdLine, CursorPos):      Auto-complete {{{3
function! BTWComplete(ArgLead, CmdLine, CursorPos)
  let tmp = substitute(a:CmdLine, '\s*\S*', 'Z', 'g')
  let pos = strlen(tmp)
  if 0
    call confirm( "AL = ". a:ArgLead."\nCL = ". a:CmdLine."\nCP = ".a:CursorPos
	  \ . "\ntmp = ".tmp."\npos = ".pos
	  \, '&Ok', 1)
  endif

  if     2 == pos
    " First argument: a command
    return s:commands
  elseif 3 == pos
    " Second argument: first arg of the command
    if     -1 != match(a:CmdLine, '^BTW\s\+echo')
      return s:functions . "\n" . s:variables
    elseif -1 != match(a:CmdLine, '^BTW\s\+\%(help\|?\)')
    elseif -1 != match(a:CmdLine, '^BTW\s\+\%(set\|add\)\%(local\)\=')
      " Adds a filter
      " let files =         globpath(&rtp, 'compiler/BT-*')
      " let files = files . globpath(&rtp, 'compiler/BT_*')
      " let files = files . globpath(&rtp, 'compiler/BT/*')
      let files = s:FindFilter('*')
      let files = substitute(files,
	    \ '\(^\|\n\).\{-}compiler[\\/]BTW[-_\\/]\(.\{-}\)\.vim\>\ze\%(\n\|$\)',
	    \ '\1\2', 'g')
      return files
    elseif -1 != match(a:CmdLine, '^BTW\s\+remove\%(local\)\=')
      " Removes a filter
      return substitute(s:FiltersList(), ',', '\n', 'g')
    endif
  endif
  " finally: unknown
  echoerr 'BTW: unespected parameter ``'. a:ArgLead ."''"
  return ''
endfunction

" BTW(command [,filter]):                        Main function {{{3
if !exists('g:BTW_BTW_in_use')
  function! s:BTW(command, ...)
    " todo: check a:0 > 1
    if     'set'      == a:command | let g:BTW_build_tool = a:1
      if exists('b:BTW_build_tool')
	let b:BTW_build_tool = a:1
      endif
    elseif 'setlocal'     == a:command | let b:BTW_build_tool = a:1
    elseif 'add'          == a:command | call s:AddFilter('g', a:1)
    elseif 'addlocal'     == a:command | call s:AddFilter('b', a:1)
      " if exists('b:BTW_filters_list') " ?????
	" call s:AddFilter('b', a:1)
      " endif
    elseif 'remove'       == a:command | call s:RemoveFilter('g', a:1)
    elseif 'removelocal'  == a:command | call s:RemoveFilter('b', a:1)
    elseif 'rebuild'      == a:command " wait for s:ReconstructToolsChain()
    elseif 'echo'         == a:command | exe "echo s:".a:1
      " echo s:{a:f1} ## don't support �echo s:f('foo')�
    elseif 'reloadPlugin' == a:command
      let g:force_reload_BuildToolsWrapper = 1
      let g:BTW_BTW_in_use = 1
      exe 'so '.s:sfile
      unlet g:force_reload_BuildToolsWrapper
      unlet g:BTW_BTW_in_use
      return
    elseif a:command =~ '\%(help\|?\)'
      call s:Usage()
      return
    endif
    call s:ReconstructToolsChain()
  endfunction
endif

" AddFilter(scope,filter):                       Exposed/public feature {{{3
function! s:AddFilter(scope, filter)
  let var = a:scope . ':BTW_filters_list'
  if     !exists(var) || 0==strlen({var})
    " let {var} = a:filter
    let {var} = ',' . a:filter
  elseif ! s:HasFilter(a:filter, var)
    let {var} = {var} . ',' . a:filter
  endif
endfunction

" RemoveFilter(scope,filter):                    Exposed/public feature {{{3
function! s:RemoveFilter(scope, filter)
  let var = a:scope . ':BTW_filters_list'

  if 'g' == a:scope
    " If global scope: remove it for every buffer
    let bnum = bufnr('%')
    exe 'bufdo call s:DoRemoveFilter("b", "'.a:filter.'")'
    " exe 'bufdo BTW removelocal '.a:filter
    exe ':buffer '.bnum
  elseif ('b' == a:scope) && !exists(var)
	\ && s:HasFilter(a:filter, var)
	" \ && (match(s:FiltersList(),a:filter) >= 0)
    " Defines a local set of filter-plugins from previous the global list
    let b:BTW_filters_list = g:BTW_filters_list
    " finally: call DoRemove
  else
    call lh#common#ErrorMsg('BTW: Error no such filter-plugin to remove "'
	  \ . a:filter . '"')
    " s:DoRemove(): kind of "big" no-op
  endif

  " Do remove it for this scope
  call s:DoRemoveFilter(a:scope, a:filter)
endfunction

function! s:DoRemoveFilter(scope,filter)
  let var = a:scope . ':BTW_filters_list'
  if exists(var)
    let {var} = substitute({var}, ','.a:filter, '', 'g')
    " unlet => can not locally remove the only filter of a global list
    " if 0 == strlen({var})
      " unlet {var}
    " endif
  endif
endfunction

" FindFilter(filter):                            Helper {{{3
function! s:FindFilter(filter)
  let filter = a:filter . '.vim'
  let result =globpath(&rtp, "compiler/BTW-".filter) . "\n" .
	\ globpath(&rtp, "compiler/BTW_".filter). "\n" .
	\ globpath(&rtp, "compiler/BTW/".filter)
  let result = substitute(result, '\n\n', '\n', 'g')
  let result = substitute(result, '^\n', '', 'g')
  return result
endfunction

" DefaultEFM():                                  {{{3
" @return default value of &efm
function! s:DefaultEFM(wanted_efm)
  " call Dfunc('s:DefaultEFM('.a:wanted_efm.')')
  let save_efm = &l:efm
  if a:wanted_efm == 'default efm'
    setlocal efm&vim
  else
    " if exists("current_compiler")
      silent! unlet b:current_compiler
      silent! unlet g:current_compiler
    " endif
    " exe 'compiler '.a:wanted_efm
    exe 'runtime compiler/'.a:wanted_efm.'.vim'
    if strlen(&makeprg) && !exists('g:BTW_filter_program_'.a:wanted_efm) && !exists('b:BTW_filter_program_'.a:wanted_efm)
      " @todo use the correct scope -> b:/g:
      let g:BTW_filter_program_{a:wanted_efm} = &makeprg
    endif
  endif
  let efm = &l:efm
  let &l:efm = save_efm
  " call Dret('s:DefaultEFM '.efm)
  return efm
endfunction

" AdjustEFM(filter, efm):                        {{{3
function! s:AdjustEFM(filter, efm)
  let added = lh#option#Get('BTW_adjust_efm_'.a:filter, '', 'bg')
  " if added =~ "default efm"
  " TODO: use split and join
    let added = substitute(added, 'default efm',
	  \ escape(s:DefaultEFM('default efm'), '\'), '')
  " endif
  if added =~ 'import:'
    let compiler_plugin_imported = matchstr(added, 'import: \zs[^,]*')
    let added = substitute(added, 'import: \%([^,]\{-}\ze\%(,\|$\)\)',
	  \ escape(s:DefaultEFM(compiler_plugin_imported), '\'), '')
  endif
  return
	\   lh#option#Get('BTW_ignore_efm_'.a:filter, '', 'bg')
	\ . a:efm
	\ . (strlen(added) ? ','.added : '')
endfunction


" LoadFilter(filter):                            {{{3
function! s:LoadFilter(filter)
  if     0 != strlen(s:FindFilter(a:filter))
    " First nominal case: there is a BTW-a:filter that will be loaded
    exe  'runtime! compiler/BTW-'.a:filter.'.vim compiler/BTW_'.a:filter.'.vim compiler/BTW/'.a:filter.'.vim'
    " echo 'runtime! compiler/BTW-'.a:filter.'.vim compiler/BTW_'.a:filter.'.vim compiler/BTW/'.a:filter.'.vim'
  elseif 0 != strlen(globpath(&rtp, 'compiler/'.a:filter.'.vim'))
    " Second case: there is a compiler plugin named {a:filter}.vim
    let b:BTW_adjust_efm_{a:filter} = 'import: '.a:filter
  elseif 0 != strlen(globpath(&rtp, 'compiler/BTW/'.a:filter.'.pl'))
    " Third case: there is a perl script compiler/BTW/{a:filter}.pl
    let g:BTW_filter_program_{a:filter} = globpath(&rtp, 'compiler/BTW/'.a:filter.'.vim') 
  elseif executable(a:filter)
    let filter = s:ToVarName(a:filter)
    let g:BTW_filter_program_{filter} = a:filter
  else
    " There is no such a:filter
  endif
endfunction

" ReconstructToolsChain():                       {{{3
function! s:ReconstructToolsChain()
  let prog = lh#option#Get('BTW_build_tool', 'make')
  if 0
    exe 'runtime! compiler/BTW-'.prog.'.vim compiler/BTW_'.prog.'.vim compiler/BTW/'.prog.'.vim'
    " TODO: if '$*' is already present in the filter_program, then don't append it.
  else
    call s:LoadFilter(prog)
  endif
  let makeprg = lh#option#Get('BTW_filter_program_'.prog, prog, 'bg') . ' $*'
  let efm     = s:AdjustEFM(prog, '')

  let filters_list = lh#option#Get('BTW_filters_list', '')
  while strlen(filters_list)
    let filter       = matchstr(filters_list, ',\zs[^,]*')
    let filters_list = matchstr(filters_list, ',[^,]*\zs.*')
    " echo filter . ' ### ' . filters_list

    call s:LoadFilter(filter)
    " let efm = efm . ',' . lh#option#Get('BTW_adjust_efm_'.filter, '', 'g')
    let efm = s:AdjustEFM(filter, efm)
    let prg = lh#option#Get(s:ToVarName('BTW_filter_program_'.filter), '', 'bg')

    if strlen(prg)
      " Faire dans BTW-{filter}.vim
      " let prg = substitute(expand('<sfile>:p:h'), ' ', '\\ ', 'g')
      let makeprg = makeprg . " 2>&1 \\| ".prg
    endif
  endwhile

  let islocal = exists('b:BTW_build_tool') || exists('b:BTW_filters_list')
  let local = islocal ? 'l:' : ''
  let set   = islocal ? 'setlocal ' : 'set '

  " Set makeprog
  exe 'let &'.local.'makeprg = makeprg'
  " set does not seems to work
  "   exe set . 'makeprg="'. makeprg . '"'
  "   exe set . 'makeprg='. escape(makeprg, '\ ')

  " Set errorformat ; strip redundant commas
  let efm = substitute(efm, ',\+', ',', "g")
  let efm = matchstr(efm, '^,*\zs.*')
  " default used ... by default
  if strlen(efm)
    " Add the new formats
    " exe set . 'efm+="'. efm . '"'
    " exe set . 'efm+='. escape(efm, '\ ')
    " exe 'let &'.local.'efm = &'.local."efm . ',' . efm"
    exe 'let &'.local.'efm = efm'
  endif
  " set efm&vim                  " Reset to default value
  " let &efm = &efm . ',' . efm  " Add the new formats
endfunction

" HasFilterGuessScope(filter): {{{3
function! s:HasFilterGuessScope(filter)
  if     exists('b:BTW_filters_list')
    return s:HasFilter(a:filter, 'b:BTW_filters_list')
  elseif exists('g:BTW_filters_list')
    return s:HasFilter(a:filter, 'g:BTW_filters_list')
  else
    return 0
  endif
endfunction

" HasFilter(filter, var): {{{3
function! s:HasFilter(filter, var)
  " do not mess with isk !!!
  let list = substitute({a:var}, ',', ' ', 'g')
  return -1 != match(list, '\<'.a:filter.'\>')
  " return -1 != match({a:var}, a:filter)
endfunction

" ToolsChain():                                  Helper {{{3
function! s:ToolsChain()
  return lh#option#Get('BTW_build_tool', 'make') .
	\ substitute (s:FiltersList(), ',', ' | ', 'g')
endfunction

" FiltersList():                                 Helper {{{3
function! s:FiltersList()
  " problem: lh#option#Get this will ignore empty variables => custom function
  if     exists('b:BTW_filters_list') | return b:BTW_filters_list
  elseif exists('g:BTW_filters_list') | return g:BTW_filters_list
  else                                | return ''
  endif
endfunction


" Usage(): {{{3
function! s:Usage()
  echo "Build Tools Wrapper: USAGE"
endfunction

" Build And Execute:                     {{{2
" TODO: distinguish rule-name for the compilation (e.g. ``all'') and the final
" executable

" Function: s:ProjectName()          {{{3
" How to define this option:
" - with a _vimrc_local file
" - with a let modeline
function! s:ProjectName()
  if     exists('b:BTW_project') | return b:BTW_project
  elseif exists('g:BTW_project') | return g:BTW_project
  else
    if &ft == 'qf' | cclose | return s:ProjectName()
    else           | return '%<'
    endif
  endif
endfunction

function! s:TargetRule()
  " TODO: find a better name
  " TODO: try to detect available rules in Makefile/main.aap/...,
  " and cache them
  if &ft == 'qf' | cclose | return s:TargetRule() | endif
  if     exists('b:BTW_project_target') | return b:BTW_project_target
  elseif exists('g:BTW_project_target') | return g:BTW_project_target
  else
    let res = s:ProjectName()
    if !strlen(res)
      res = 'all' " just a guess
    endif
    return res
  endif
endfunction

function! s:Executable()
  " TODO: find a better name
  " TODO: try to detect available rules in Makefile/main.aap/...,
  " and cache them
  if &ft == 'qf' | cclose | return s:Executable() | endif
  if     exists('b:BTW_project_executable') | return b:BTW_project_executable
  elseif exists('g:BTW_project_executable') | return g:BTW_project_executable
  else
    let res = s:ProjectName()
    if !strlen(res)
      " TODO: glob()+executable() -> possible executable in the build
      " directory
    endif
    return res
  endif
endfunction

" Load mappings for quickfix windows {{{3
" TODO: delete this part
" augroup compile
  " au!
  " au FileType qf :call <sid>DefQuickFixMappings()
" augroup END

function! s:DefQuickFixMappings()
  exe '  nnoremap <buffer> '.s:key_make   .':call <sid>CompileQF()<cr>'
  exe '  inoremap <buffer> '.s:key_make   .'<c-o>:call <sid>CompileQF()<cr>'

  exe '  nnoremap <buffer> '.s:key_execute.':call <sid>Execute()<cr>'
  exe '  inoremap <buffer> '.s:key_execute.'<c-o>:call <sid>Execute()<cr>'
endfunction


" Function: s:Compile([target])      {{{3
function! s:Compile(...)
    update
    if a:0 > 0 && strlen(a:1)
      let rule = a:1
    else
      let rule = s:TargetRule()
    endif
    " else ... pouvoir avoir s:TargetRule() . a:1 ; si <bang> ?!


    let bg = has('clientserver') && lh#option#Get('BTW_make_in_background', 0)
    if bg
      let run_in = lh#option#Get("BTW_make_in_background_in", '')
      if strlen(run_in)
	" Typically xterm -e
	let run_in = ' --program="'.run_in.'"'
      endif
      let save_makeprg = &makeprg
      let &makeprg = s:RunInBackground()
	    \ . ' --vim=' . v:progname
	    \ . ' --servername=' . v:servername
	    \ . run_in
	    \ . ' "' . (save_makeprg) . '"'
	    " \ . ' "' . escape(save_makeprg, '|') . '"'
    endif

    if lh#system#OnDOSWindows() && bg
      let cmd = ':!start '.substitute(&makeprg, '\$\*', rule, 'g')
      let g:toto = cmd
      exe cmd
    else
      exe 'make! '. rule
    endif

    if bg
      let &makeprg = save_makeprg
    endif

    call s:ShowError()
endfunction

" Function: s:ShowError([cop|cwin])  {{{3
function! s:ShowError(...)
  let qf_position = lh#option#Get('BTW_qf_position', '', 'g')

  if a:0 == 1 && a:1 =~ '^\%(cw\%[window]\|copen\)$'
    let open_qf = a:1
  else
    let open_qf = 'cwindow'
  endif

  " --- The following code is borrowed from LaTeXSuite
  " close the quickfix window before trying to open it again, otherwise
  " whether or not we end up in the quickfix window after the :cwindow
  " command is not fixed.
  let winnum = winnr()
  cclose
  exe qf_position . ' ' . open_qf

  setlocal nowrap

  " if we moved to a different window, then it means we had some errors.
  if winnum != winnr()
    " resize the window to just fit in with the number of lines.
    let nl = 15 > &winfixheight ? 15 : &winfixheight
    let nl = lh#option#Get('BTW_QF_size', nl, 'g')
    let nl = line('$') < nl ? line('$') : nl
    exe nl.' wincmd _'

    " Apply syntax hooks
    let syn = lh#option#Get('BTW_qf_syntax', '', 'gb')
    if strlen(syn)
      silent exe 'runtime compiler/BTW/syntax/'.syn.'.vim'
    endif
  endif
  if lh#option#Get('BTW_GotoError', 1, 'g') == 1
  else
    exe origwinnum . 'wincmd w'
  endif
endfunction

" Function: s:CopenBG(f,[cop|cwin])  {{{3
function! s:CopenBG(errorfile,...)
  " Load a file containing the errors
  :exe ":cgetfile ".a:errorfile
  " delete the temporary file
  if a:errorfile =~ 'tmp-make-bg'
    call delete(a:errorfile)
  endif
  let opt = (a:0>0) ? a:1 : ''
  exe 'call s:ShowError('.opt.')'
  echohl WarningMsg
  echo "Build complete!"
  echohl None
endfunction

" Function: s:ToggleMakeInBG()       {{{3
function! s:ToggleMakeInBG()
  let value = lh#option#Get('BTW_make_in_background', 0, 'g')
  let g:BTW_make_in_background = 1 - value

  call s:MenuMakeBG()
endfunction

" Function: s:CompileQF()            {{{3
" TODO: delete this part
function! s:CompileQF()
  cclose
  call s:Compile()
endfunction

" Function: s:Execute()              {{{3
let s:ext = (has('win32')||has('win64')||has('win16')) ? '.exe' : ''
function! s:Execute()
  let path = s:Executable()
  if (SystemDetected() == 'unix') && (path[0]!='/')
    let path = './' . path
  endif
  exe ':!'.path . s:ext . ' ' .lh#option#Get('BTW_run_parameters','')
endfunction

" Function: s:ExecuteQF()            {{{3
" TODO: delete this part
function! s:ExecuteQF()
  :!./#<.exe
endfunction

" Function: s:AddLetModeline()       {{{3
" Meant to be used with let-modeline.vim
function! s:AddLetModeline()
  " TODO: add support for scons, A-A-P, ... (hook ?)
  " TODO: become smart: auto detect makefile, A-A-P, scons, ...

  " Check is there is already a Makefile or an A-A-P recipe.
  let aap_files  = glob('*.aap')
  if strlen(aap_files)
    let aap_files  = substitute("\n".aap_files, '\n', '\0Edit \&', 'g')
  endif
  let make_files = glob('Makefile*')
  if strlen(make_files)
    let make_files = substitute("\n".make_files, '\n', '\0Edit \&', 'g')
  elseif !strlen(aap_files)
    let aap_files  = "\nEdit &main.aap"
    let make_files = "\nEdit &Makefile"
  endif

  let which = WHICH('COMBO', 'Which option must be set ?',
	\ "Abort"
	\ . aap_files . make_files
	\ . "\n$&CFLAGS\n$C&PPFLAGS\n$C&XXFLAGS"
	\ . "\n$L&DFLAGS\n$LD&LIBS"
	\ . "\n&g:BTW_project\n&b:BTW_project"
	\ )
  if which =~ 'Abort\|^$'
    " Nothing to do
  elseif which =~ '^Edit.*$'
    exe 'sp '. matchstr(which, 'Edit\s*\zs.*')
  else
    below split
    let s = search('Vim:\s*let\s\+.*'.which.'\s*=\zs')
    if s <= 0
      let l = '// Vim: let '.which."='".Marker_Txt(which)."'"
      silent $put=l
    endif
  endif
endfunction


" Internals }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
