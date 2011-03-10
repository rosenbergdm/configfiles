"=============================================================================
" $Id: repl-visual-no-reg-overwrite.vim 143 2009-02-19 02:04:34Z luc.hermitte $
" File:		repl-visual-no-reg-overwrite.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	«version»
" Created:	14th Nov 2008
" Last Update:	$Date: 2009-02-18 20:04:34 -0600 (Wed, 18 Feb 2009) $
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
" I haven't found how to hide this function (yet)
function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction

function! s:Repl()
    let s:restore_reg = @"
    return "p@=RestoreRegister()\<cr>"
endfunction

" This supports "rp that permits to replace the visual selection with the
" contents of @r
vnoremap <silent> <expr> p <sid>Repl()

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
