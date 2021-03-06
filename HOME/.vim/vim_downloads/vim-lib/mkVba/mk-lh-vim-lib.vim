"=============================================================================
" $Id: mk-lh-vim-lib.vim 118 2008-10-27 00:29:33Z luc.hermitte $
" File:		mk-lh-lib.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	2.1.0
let s:version = '2.2.0'
" Created:	06th Nov 2007
" Last Update:	$Date: 2008-10-26 19:29:33 -0500 (Sun, 26 Oct 2008) $
"------------------------------------------------------------------------
cd <sfile>:p:h
try 
  let save_rtp = &rtp
  let &rtp = expand('<sfile>:p:h:h').','.&rtp
  exe '22,$MkVimball! lh-vim-lib-'.s:version
  set modifiable
  set buftype=
finally
  let &rtp = save_rtp
endtry
finish
autoload/lh/askvim.vim
autoload/lh/buffer.vim
autoload/lh/buffer/dialog.vim
autoload/lh/command.vim
autoload/lh/common.vim
autoload/lh/event.vim
autoload/lh/encoding.vim
autoload/lh/list.vim
autoload/lh/menu.vim
autoload/lh/option.vim
autoload/lh/path.vim
autoload/lh/position.vim
autoload/lh/syntax.vim
autoload/lh/visual.vim
autoload/lh/graph/tsort.vim
doc/lh-vim-lib.txt
macros/menu-map.vim
plugin/ui-functions.vim
plugin/words_tools.vim
tests/lh/test-Fargs2String.vim
tests/lh/test-askmenu.vim
tests/lh/test-command.vim
tests/lh/test-menu-map.vim
tests/lh/test-toggle-menu.vim
tests/lh/topological-sort.vim
