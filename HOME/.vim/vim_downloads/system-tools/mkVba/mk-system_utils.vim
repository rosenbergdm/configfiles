"=============================================================================
" $Id: mk-system_utils.vim 25 2008-02-14 02:18:28Z luc.hermitte $
" File:		mk-system_utils.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	2.0.0
" Created:	06th Nov 2007
" Last Update:	$Date: 2008-02-13 20:18:28 -0600 (Wed, 13 Feb 2008) $
"------------------------------------------------------------------------
cd <sfile>:p:h
let save_rtp = &rtp
let &rtp = expand('<sfile>:p:h:h').','.&rtp
18,$MkVimball! system_utils
set modifiable
set buftype=
let &rtp = save_rtp
finish
autoload/lh/system.vim
doc/system_utils.txt
plugin/system_utils.vim
