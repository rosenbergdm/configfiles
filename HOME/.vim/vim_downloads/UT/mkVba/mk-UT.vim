"=============================================================================
" $Id: mk-UT.vim 151 2009-02-21 16:04:50Z luc.hermitte $
" File:		mk-UT.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	0.0.2
let s:version = '0.0.2'
" Created:	19th Feb 2009
" Last Update:	$Date: 2009-02-21 10:04:50 -0600 (Sat, 21 Feb 2009) $
"------------------------------------------------------------------------
cd <sfile>:p:h
try 
  let save_rtp = &rtp
  let &rtp = expand('<sfile>:p:h:h').','.&rtp
  exe '22,$MkVimball! UT-'.s:version
  set modifiable
  set buftype=
finally
  let &rtp = save_rtp
endtry
finish
autoload/lh/UT.vim
ftplugin/vim/vim_UT.vim
mkVba/mk-UT.vim
plugin/UT.vim
tests/lh/UT-fixtures.vim
tests/lh/UT.vim
UT.README
