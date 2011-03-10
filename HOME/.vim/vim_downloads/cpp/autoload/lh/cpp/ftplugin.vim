"=============================================================================
" $Id: ftplugin.vim 124 2008-10-28 00:30:43Z luc.hermitte $
" File:		ftplugin.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	1.0.0
" Created:	11th Sep 2008
" Last Update:	$Date: 2008-10-27 19:30:43 -0500 (Mon, 27 Oct 2008) $
"------------------------------------------------------------------------
" Description:	«description»
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------

function! lh#cpp#ftplugin#OptionalClass(...)
  if a:0 != 0
    if     type(a:1) == type("") && strlen(a:1)>0
      return a:1
    elseif type(a:1) == type([])
      if len(a:1) > 0 && strlen(a:1[0]) > 0
	return a:1[0]
      endif
    endif
  endif

  let classname = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'),'class')
  return classname
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
