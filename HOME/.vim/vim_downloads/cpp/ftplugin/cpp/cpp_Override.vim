"=============================================================================
" $Id: cpp_Override.vim 124 2008-10-28 00:30:43Z luc.hermitte $
" File:		cpp_Override.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	1.0.0
" Created:	15th Apr 2008
" Last Update:	$Date: 2008-10-27 19:30:43 -0500 (Mon, 27 Oct 2008) $
"------------------------------------------------------------------------
" Description:	�description�
" 
"------------------------------------------------------------------------
" Installation:	�install details�
" History:	�history�
" TODO:		�missing features�
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if exists("b:loaded_ftplug_cpp_Override") && !exists('g:force_reload_ftplug_cpp_Override')
  finish
endif
let b:loaded_ftplug_cpp_Override = 100
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=? Override :call lh#cpp#override#Main(<f-args>)

"=============================================================================
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
