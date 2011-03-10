"|fld   description : some template helper functions
"|fld   keywords : <+ this is used to index / group scripts ?+> 
"|fld   initial author : Marc Weber marco-oweber@gmx.de
"|fld   mantainer : author
"|fld   started on : 2006 Dec 04 01:04:01
"|fld   version: 0.0
"|fld   dependencies: <+ vim-python, vim-perl, unix-tool sed, ... +>
"|fld   contributors : <+credits to+>
"|fld   tested on os : <+credits to+>
"|fld   maturity: unusable, experimental
"|fld     os: <+ remove this value if script is os independent +>
"|
"|H1__  Documentation
"|
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
"let s:setting=vl#lib#vimscript#scriptsettings#Load('vl.dev.haskell.template_helper_functions.<+setting_name+>',<+ default +>)
"|
"|
"|hist <+ historical information. (Which changes have been made ?) +>
"|
"|TODO:  write more documentation
"|+      
"|+      
"|rm roadmap (what to do, where to go?)

"|func searches the last data xy and returns xy
function! vl#dev#haskell#template_helper_functions#DataDeclarationTypeAboveCursor()
  let expr = '^data\s*\zs\w*\ze'
  let save_cursor = getpos(".")
  let result = ""
  if search(expr,'b')
    let a = @"
    exec 'normal y/'.expr."/e\<cr>"
    let result = @"
    let g:result = result
    let @" = a
  endif
  call setpos('.', save_cursor)
  return result
endfunction
