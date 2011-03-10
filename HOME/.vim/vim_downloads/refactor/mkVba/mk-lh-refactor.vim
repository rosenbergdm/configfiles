"=============================================================================
" $Id: mk-lh-refactor.vim 131 2008-10-28 01:38:55Z luc.hermitte $
" File:		mk-lh-refactor.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	0.0.3
" Created:	06th Nov 2007
" Last Update:	$Date: 2008-10-27 20:38:55 -0500 (Mon, 27 Oct 2008) $
"------------------------------------------------------------------------
cd <sfile>:p:h
15,$MkVimball! lh-refactor
set modifiable
set buftype=
finish
plugin/refactor.vim
doc/refactor.txt
