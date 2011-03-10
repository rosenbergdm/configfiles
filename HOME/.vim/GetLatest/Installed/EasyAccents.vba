451 9231 :AutoInstall: EasyAccents.vim
UseVimball
finish
plugin/EasyAccents.vim	[[[1
282
" EasyAccents.vim: converts a` a' etc during insert mode
"
"  Author:  Charles E. Campbell, Jr. (PhD)
"  Date:    Sep 08, 2008
"  Version: 9
" Copyright:    Copyright (C) 1999-2008 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               Align.vim is provided *as is* and comes with no warranty
"               of any kind, either expressed or implied. By using this
"               plugin, you agree that in no event will the copyright
"               holder be liable for any damages resulting from the use
"               of this software.
"
"
" "For I am convinced that neither death nor life, neither angels nor demons,
"  neither the present nor the future, nor any powers, nor height nor depth,
"  nor anything else in all creation, will be able to separate us from the
"  love of God that is in Christ Jesus our Lord."  Rom 8:38
"
" GetLatestVimScripts: 451 1 EasyAccents.vim
" =======================================================================
if &cp
 finish
endif
let s:keepcpo= &cpo
set cpo&vim

" ---------------------------------------------------------------------
" Full Load Once: {{{1
if !exists("g:loaded_EasyAccents")
 " Default Option Values: {{{2
 let g:loaded_EasyAccents = "v9"
 let b:EasyAccentsOn      = 0

 if !exists("g:EasyAccents_VowelFirst")
  let g:EasyAccents_VowelFirst= 1
 endif

 " Public Interface: {{{2
 if !hasmapto('<Plug>ToggleEasyAccents')
  map  <unique> <Leader>eza <Plug>ToggleEasyAccents
  imap <unique> <Leader>eza <Plug>InsToggleEasyAccents
 endif
 map  <silent> <script> <Plug>ToggleEasyAccents    :set lz<CR>:call <SID>ToggleEasyAccents()<CR>:set nolz<CR>
 imap <silent> <script> <Plug>InsToggleEasyAccents <c-o>:set lz<bar>:call <SID>ToggleEasyAccents()<bar>:set nolz<CR>
 com! -nargs=0 EZA	call s:ToggleEasyAccents()

 " ---------------------------------------------------------------------
 " EasyAccents: {{{2
 fun! <SID>EasyAccents()
"  call Dfunc("EasyAccents() col=".col(".")." ve<".&ve."> vowelfirst=".g:EasyAccents_VowelFirst)

  " maintain control over virtual edit mode
  let vekeep = &ve
  set ve=
  if col(".") < 2
   let &ve=vekeep
"   call Dret("EasyAccents : col < 2")
   return
  endif

  " Save Registers
  let akeep     = @a
  let bkeep     = @b

  let didinsert = 0
  if col(".") < col("$")-1
   " inserting inside a line
   norm! h
   let didinsert= 1
"   call Decho("inserted inside a line")
  endif
  norm! "ayhl
  norm! v"by

  " not an accent and accent first
  if !g:EasyAccents_VowelFirst && @a !~ "[`'^:~,]"
   let @a = akeep
   let @b = bkeep
   let &ve= vekeep
   if !g:EasyAccents_VowelFirst || (&ve != "" && &ve != "block")
    norm! l
   endif
"   call Dret("EasyAccents : not an accent and accent first")
   return
  endif

  if didinsert
   norm! hx
  else
   norm! x
  endif

  " get accent and vowel
  if g:EasyAccents_VowelFirst
   let accent = @b
   let vowel  = @a
  else
   let accent = @a
   let vowel  = @b
  endif

  " change (some) accents
  let origaccent= accent
  if accent == "`"
   let accent= "!"
  elseif accent == "^"
   let accent= ">"
  elseif accent == "~"
   let accent= "?"
  endif
"  call Decho("accent<".accent."> vowel<".vowel.">")

  if accent == ","

   if vowel =~ "[cC]"
    exe "norm! r\<c-k>".vowel.accent
   elseif vowel =~ "[bB]"
    exe "norm! r\<c-k>ss"
   elseif vowel == '\'
	exe "norm! r".accent
   elseif g:EasyAccents_VowelFirst == 1
	exe "norm! R".vowel.origaccent
   else
	exe "norm! R".origaccent.vowel
   endif

  elseif accent == '@'
   if vowel =~ "[aA]"	" thanks to Martin Karlsson
   	exe "norm! r\<c-k>".vowel.vowel
   elseif vowel =~ "e"
   	exe "norm! r\<c-k>ae"
   elseif vowel =~ "E"
   	exe "norm! r\<c-k>AE"
   elseif vowel =~ "?"
   	exe "norm! r\<c-k>?I"
   elseif vowel =~ "o"
   	exe "norm! r\<c-k>oe"
   elseif vowel =~ "O"
   	exe "norm! r\<c-k>OE"
   elseif vowel =~ "@"
   	exe "norm! r\<c-k>O/"
   elseif vowel =~ "p"
   	exe "norm! r\<c-k>TH"
   elseif vowel =~ "u"
   	exe "norm! r\<c-k>My"
   elseif vowel =~ "d"
   	exe "norm! r\<c-k>d-"
   elseif vowel =~ "D"
   	exe "norm! r\<c-k>D-"
   elseif vowel =~ "x"
   	exe "norm! r\<c-k>*X"
   elseif vowel =~ "r"
   	exe "norm! r\<c-k><r"
   elseif vowel =~ "!"
   	exe "norm! r\<c-k>!I"
   elseif vowel == '\'
	exe "norm! r".accent
   elseif g:EasyAccents_VowelFirst == 1
	exe "norm! R".vowel.origaccent
   else
	exe "norm! R".origaccent.vowel
   endif

  else

   if vowel =~ "[aAeEiIoOuUyY]"
    exe "norm! r\<c-k>".vowel.accent
   elseif vowel =~ "[Nn]" && accent == '?'
    exe "norm! r\<c-k>".vowel.accent
  
   elseif vowel == '\'
   	exe "norm! r".origaccent
   elseif g:EasyAccents_VowelFirst == 1
	exe "norm! R".vowel.origaccent
   else
	exe "norm! R".origaccent.vowel
   endif
  endif
 
  let @a = akeep
  let @b = bkeep
  let &ve= vekeep
  if !g:EasyAccents_VowelFirst || (&ve != "" && &ve != "block")
   norm! l
  endif
"  call Dret("EasyAccents")
 endfun

 " ---------------------------------------------------------------------
 " ToggleEasyAccents: {{{2
 fun! <SID>ToggleEasyAccents()
  if b:EasyAccentsOn == 0 " -----------------------------------------
   " Turn EasyAccents on
   let b:EasyAccentsOn= 1
   
   if g:EasyAccents_VowelFirst
    " this function provides the preceding character with an accent mark
    inoremap <silent> `  `<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> '  '<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> ^  ^<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> :  :<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> ~  ~<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> ,  ,<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> @  @<c-o>:call <SID>EasyAccents()<CR>

   else
    " this function examines the preceding character for accent mark
    inoremap <silent> a  a<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> A  A<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> b  b<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> B  B<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> c  c<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> C  C<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> D  D<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> e  e<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> E  E<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> i  i<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> I  I<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> N  N<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> o  o<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> O  O<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> p  p<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> u  u<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> U  U<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> x  x<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> y  y<c-o>:call <SID>EasyAccents()<CR>
    inoremap <silent> Y  Y<c-o>:call <SID>EasyAccents()<CR>
   endif
  
   echo "EasyAccents enabled"
   
  else " -----------------------------------------------------------------
   " Turn EasyAccents off
   let b:EasyAccentsOn= 0
   if g:EasyAccents_VowelFirst
    iunmap `
    iunmap '
    iunmap ^
    iunmap :
    iunmap ~
    iunmap ,
   else
   	iunmap a
   	iunmap A
   	iunmap b
   	iunmap B
   	iunmap c
   	iunmap C
   	iunmap D
   	iunmap e
   	iunmap E
   	iunmap i
   	iunmap I
   	iunmap N
   	iunmap o
   	iunmap O
   	iunmap p
   	iunmap u
   	iunmap U
   	iunmap x
   endif
  
   echo "EasyAccents disabled"
  endif " ----------------------------------------------------------------
 endfun

 " Restore: {{{2
 let &cpo= s:keepcpo
 unlet s:keepcpo
 finish
endif

" ---------------------------------------------------------------------
"  Toggle EasyAccents Mode: {{{1
call <SID>ToggleEasyAccents()
let &cpo= s:keepcpo
unlet s:keepcpo
" ---------------------------------------------------------------------
" vim: fdm=marker
doc/EasyAccents.txt	[[[1
122
*EasyAccents.txt*	EasyAccents				Sep 08, 2008

Author:  Charles E. Campbell, Jr.  <NdrOchip@ScampbellPfamily.AbizM>
	  (remove NOSPAM from Campbell's email first)
Copyright: (c) 2004-2008 by Charles E. Campbell, Jr.	*easyaccents-copyright*
           The VIM LICENSE applies to EasyAccents.vim and EasyAccents.txt
           (see |copyright|) except use "EasyAccents" instead of "Vim"
	   No warranty, express or implied.  Use At-Your-Own-Risk.

==============================================================================
1. Contents    				*easyaccents* *easyaccents-contents*

	1. Contents.................: |easyaccents-contents|
	2. EasyAccents Manual.......: |easyaccents-manual|
	3. Installation.............: |easyaccents-install|
	4. EasyAccents History......: |easyaccents-history|

==============================================================================

2. EasyAccents Manual  					*easyaccents-manual*
	
TOGGLING EASYACCENTS ON AND OFF				*\eza*
	The map >
		\eza
<	will toggle EasyAccents on and off.  Actually, its >
		<Leader>eza
<	so you may specify the leading character for the map.

							*:EZA*
	Alternatively, you may use the >
		:EZA
<	command to toggle EasyAccents between on and off.

USING EASYACCENTS
	 These maps all work during insert mode.  Type a' a` A' c, etc and
	 accented characters result.  ([aeioubcAEIOUBC], then accent)
	
	 If you want a vowel (or [bBcC]) to be followed by an accent,
	 use a backslash to escape it:  a\'  for example will become a'
	
	 Sourcing this file acts as a toggle to switch EasyAccents on
	 and off.  By default, the mapping <Leader>eza will toggle
	 EasyAccents, too, by calling <Plug>ToggleEasyAccents .
	
	 If g:EasyAccents_VowelFirst is set to zero in your <.vimrc>,
	   then                'a `a `A ,b ,c  etc.
	   (gvim) will map to   Ã¡  Ã   Ã  Ã  Ã§
	   (accent, then [aeioubcAEIOUBC])
	
	 If g:EasyAccents_VowelFirst is set to one in your <.vimrc> (also default)
	   then                a' a` A` b, c,  etc.
	   (gvim) will map to  Ã¡  Ã   Ã  Ã  Ã§
	   ([aeioubcAEIOUBC], then accent)
	
	 New with version 6:
	   Also          a@ A@ D@ e@ E@ N~ p@ u@ x@
	   (gvim) map to  Ã¥ Ã  Ã  Ã¦  Ã  Ã  Ã  Âµ  Ã

	 New with version 9: (thanks to Kevin Monceaux)
	                 ?@ !@ n~ o~ d@
			 Â¿  Â¡  Ã±  Ãµ  Ã°
	
	Caveat: the maps will not work if "set paste" is on, so that's
	        another way to bypass EasyAccents as needed.

						*easyaccents-table*
		    EasyAccent Sequence : Output Table
	     +------------------------------------------------+
	     | S  O     S  O     S  O    S  O    S  O    S  O |
	     | E  U     E  U     E  U    E  U    E  U    E  U |
	     | Q  T     Q  T     Q  T    Q  T    Q  T    Q  T |
	     +------------------------------------------------+
	     | a' Ã¡     e' Ã©     i' Ã­    o' Ã³    u' Ãº    y' Ã½ |
	     | a` Ã      e` Ã¨     i` Ã¬    o` Ã²    u` Ã¹    y` á»³ |
	     | a~ Ã£     e~ áº½     i~ Ä©    o~ Ãµ    u~ Å©    y~ á»¹ |
	     | a: Ã¤     e: Ã«     i^ Ã®    o: Ã¶    u: Ã¼    y: Ã¿ |
	     | a^ Ã¢     e^ Ãª     i: Ã¯    o^ Ã´    u^ Ã»    y^ Å· |
	     | A' Ã     E' Ã     I' Ã    o@ Å    U' Ã    Y' Ã |
	     | A` Ã     E` Ã     I` Ã    O' Ã    U` Ã    Y` á»² |
	     | A~ Ã     E~ áº¼     I~ Ä¨    O` Ã    U~ Å¨    Y~ á»¸ |
	     | A: Ã     E: Ã     I: Ã    O~ Ã    U: Ã    Y: Å¸ |
	     | A^ Ã     E^ Ã     I^ Ã    O: Ã    U^ Ã    Y^ Å¶ |
	     | a@ Ã¥     e@ Ã¦             O^ Ã    u@ Âµ         |
	     | A@ Ã     E@ Ã             O@ Å                 |
	     +------------------------------------------------+
             | b, Ã     C, Ã     D@ Ã    r@ Å    x@ Ã    !@ Â¡ |
             | c, Ã§     d@ Ã°     N~ Ã    x@ Ã    ?@ Â¿    @@ Ã |
	     +------------------------------------------------+


==============================================================================

3. Installation						*easyaccents-install*

	EasyAccents is now designed to be toggled on and off.  When on it may
	interfere with programming languages which often use characters such
	as single-quotes, backquotes, etc.


==============================================================================

4. EasyAccents History					*easyaccents-history*

v9 Jan 28, 2005 : * moved usage and installation instructions to this help file
                  * g:loaded_EasyAccents (containing version number when loaded)
		    is now separated from b:EasyAccentsOn, which indicates if
		    EasyAccents is enabled/disabled on a buffer-by-buffer basis
		  * Now includes mappings for y and Y as vowels
		  * Now includes a mapping for r@ (Å)
   Feb 04, 2008   * Included additional accented character support
   		    (Ã± Ã° Â¿ Â¡ and a \@ fix, tnx to Kevin Monceaux)
   Aug 12, 2008   * :EZA command implemented
v8 May 25, 2004 : * changed \ea to \eza to make EasyAccents cooperate with
                    engspchk
v7 May 19, 2004 : * bugfix: first-column, no virtual edit -> no accented
                    character.  Fixed
v6 Nov 18, 2003 : * maps for a@ A@ D@ e@ E@ N~ p@ u@ x@ now included
v5 Aug 21, 2003 : * included g:EasyAccents_VowelFirst option
                  * fixed insert vs append bug

==============================================================================
vim:tw=78:ts=8:ft=help:ma:fenc=utf8:noma
