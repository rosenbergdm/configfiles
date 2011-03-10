"|fld   description : use linux locate command to find files to open
"|fld   keywords : locate 
"|fld   initial author : Marc Weber marco-oweber@gmx.de
"|fld   mantainer : author
"|fld   started on : 2006 Dec 16 00:16:13
"|fld   version: 0.0
"|fld   dependencies: locate cammand from linux
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
"|ftp   " <+ description +>
"|      command! -nargs=1 LocateEdit :exec 'e '.vl#ui#navigation#locate_edit#LetUserSelectLocateFileIfThereIsAChoice(<f-args>)
"|p     like gf but uses locate edit with file under cursor (useful for include files etc)
"|ftp   noremap gl :exec 'e '.vl#ui#navigation#locate_edit#LetUserSelectLocateFileIfThereIsAChoice(expand('<cfile>'))<cr>
"|
"|H2__  settings
"|set   <description of setting(s)>
"|      "description
let s:locate=vl#lib#vimscript#scriptsettings#Load('vl.ui.navigation.locate_edit.locate_executabel','locate')
"|
"|
"|hist <+ historical information. (Which changes have been made ?) +>
"|
"|TODO:  <+ its a good start to write a list to do first+>
"|+      
"|+      
"|+      
"|rm roadmap (what to do, where to go?)

"|func returns [<list of files>, <list of warnings>]
"|     list of warning contains typically "warning: locate: warning: database /var/lib/slocate/slocate.db' is more than 8 days old"
"|p    optional parameter specefies arguments passed to locate (eg pass '-r' to use a posix
"|+    regular expr
function! vl#ui#navigation#locate_edit#GetLocateFileList(search_string,...)
  exec vl#lib#brief#args#GetOptionalArg('args',string(''))
  let lines = split(system(s:locate.' '.args.' '.a:search_string),"\n")
  let warnings = filter(deepcopy(lines),"v:val =~ 'warning:'")
  let files = filter(lines,"v:val !~ 'warning:'")
  echo join(warnings)
  return [files, warnings]
endfunction

"|func lets the user select one file which can be used to define this command:
"|code command -nargs=1 LocateEdit :exec 'e '.vl#ui#navigation#locate_edit#LetUserSelectLocateFileIfThereIsAChoice(<f-args>)
"|p    optional arg: see GetLocateFileList
function! vl#ui#navigation#locate_edit#LetUserSelectLocateFileIfThereIsAChoice(search_string,...)
  exec vl#lib#brief#args#GetOptionalArg('args',string(''))
  let [files, warnings] = vl#ui#navigation#locate_edit#GetLocateFileList(a:search_string, args)
  if len(warnings) > 0
    echo join(warnings, "\n")
  endif
  return vl#ui#userSelection#LetUserSelectIfThereIsAChoice('locate did return multiple matches. choose one', files)
endfunction
