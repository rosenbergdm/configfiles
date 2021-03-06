"=============================================================================
" $Id: mk-SiR.vim 77 2008-04-07 08:04:53Z luc.hermitte $
" File:		mk-SiR.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	2.1.7
let s:version = '2.1.7'
" Created:	06th Nov 2007
" Last Update:	$Date: 2008-04-07 03:04:53 -0500 (Mon, 07 Apr 2008) $
"------------------------------------------------------------------------
cd <sfile>:p:h
try 
  let save_rtp = &rtp
  let &rtp = expand('<sfile>:p:h:h').','.&rtp
  exe '22,$MkVimball! searchInRuntime-'.s:version
  set modifiable
  set buftype=
finally
  let &rtp = save_rtp
endtry
finish
doc/searchInRuntime.txt
plugin/searchInRuntime.vim
