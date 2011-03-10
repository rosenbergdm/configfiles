"|fld   description : provide some basic settings for vimlib
"|fld   keywords : <+ this is used to index / group scripts ?+> 
"|fld   initial author : Marc Weber marco-oweber@gmx.de
"|fld   mantainer : author
"|fld   started on : 2006 Nov 01 09:44:07
"|fld   version: 0.0
"|fld   dependencies: <+ vim-python, vim-perl, unix-tool sed, ... +>
"|fld   contributors : <+credits to+>
"|fld   maturity: stable
"|
"|H1__  Documentation
"|
"|H2__  settigns
"|set   <description of setting(s)>
"| function! a#Dotvim()
"|
"|hist <+ historical information. (Which changes have been made ?) +>
"|
"|TODO:  <+ its a good start to write a list to do first+>

let s:vimlibdir = substitute(expand('<sfile>'),'[\//]autoload.*','','').'/'

"|func the .vim or vimfiles directory containning your plugins and so on...
function! vl#settings#DotvimDir()
  if !exists('g:dotvim')
    let g:dotvim = substitute(&runtimepath,',.*','','')
  endif
  return g:dotvim.'/'
endfunction

function! vl#settings#VimlibDir()
  return s:vimlibdir
endfunction
