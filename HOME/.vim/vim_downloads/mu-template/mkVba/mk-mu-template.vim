"=============================================================================
" $Id: mk-mu-template.vim 78 2008-04-07 08:06:13Z luc.hermitte $
" File:		mk-mu-template.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	2.0.2
let s:version = '2.0.2'
" Created:	06th Nov 2007
" Last Update:	$Date: 2008-04-07 03:06:13 -0500 (Mon, 07 Apr 2008) $
"------------------------------------------------------------------------
cd <sfile>:p:h
try 
  let save_rtp = &rtp
  let &rtp = expand('<sfile>:p:h:h').','.&rtp
  exe '22,$MkVimball! mu-template-'.s:version
  set modifiable
  set buftype=
finally
  let &rtp = save_rtp
endtry
finish
after/plugin/mu-template.vim
after/template/MyProject-file-header.template
after/template/c.template
after/template/c/do.template
after/template/c/for.template
after/template/c/fori.template
after/template/c/if.template
after/template/c/internals/c-file-header.template
after/template/c/internals/c-header-typical.template
after/template/c/internals/c-header.template
after/template/c/internals/c-imp.template
after/template/c/switch.template
after/template/c/while.template
after/template/cpp.template
after/template/cpptu-header.template
after/template/cppunit-header.template
after/template/help.template
after/template/html.template
after/template/perl.template
after/template/tcl.template
after/template/template.template
after/template/test-included.template
after/template/test.template
after/template/tex/center.template
after/template/tex/figure.template
after/template/tex/frame-beamer.template
after/template/tex/frame-vhelp-beamer.template
after/template/vim.template
after/template/vim/foreach.template
after/template/vim/fori.template
after/template/vim/internals/vim-autoload-plugin.template
after/template/vim/internals/vim-footer.template
after/template/vim/internals/vim-ftplugin.template
after/template/vim/internals/vim-header.template
after/template/vim/internals/vim-other-scripts.template
after/template/vim/internals/vim-plugin.template
after/template/vim/loop-arg.template
after/template/xslt/xsl-attribute.template
after/template/xslt/xsl-for-each.template
after/template/xslt/xsl-if.template
after/template/xslt/xsl-otherwise.template
after/template/xslt/xsl-template-match.template
after/template/xslt/xsl-template-name.template
after/template/xslt/xsl-value-of.template
after/template/xslt/xsl-when.template
doc/mu-template.txt
ftplugin/template.vim
syntax/2html.vim
