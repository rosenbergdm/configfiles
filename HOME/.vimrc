scriptencoding utf-8

" colorscheme spicycodegui
" colorscheme github256
colorscheme ir_black

set shell=zsh

" Enable filetype-specific indenting and plugins
filetype plugin indent on

" Explicitly set 256 color support
set t_Co=256

" Change <Leader> and <LocalLeader>
let mapleader = ","
let maplocalleader = ","

set nocompatible
syntax on

set showmatch
set wildmenu
set wildmode=list:longest,full
set vb t_vb=
" Enable error files & error jumping.
set cf
" Set to auto read when a file is changed from the outside
set autoread



" * Text Formatting -- General

" don't make it look like there are line breaks where there are none
set nowrap

" use indents of 2 spaces, and have them copied down lines:
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent

" line numbers
set number
set numberwidth=3

" Make backspace work in insert mode
set backspace=indent,eol,start


" * File Browsing

" Settings for explorer.vim
let g:explHideFiles='^\~'

" * Window splits

" Open new horizontal split windows below current
set splitbelow

" Open new vertical split windows to the right
set splitright

" * Quick keybindings

" Quick, jump out of insert mode while no one is looking
imap ii <Esc>

" Remap F1 from Help to ESC.  No more accidents
nmap <F1> <Esc>
map! <F1> <Esc>

" Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap Y y$

" Let syntastic open the error list
" let g:syntastic_auto_loc_list=1

" Add RebuildTagsFile function/command
function! s:RebuildTagsFile()
  !ctags -R --exclude=coverage --exclude=files --exclude=public --exclude=log --exclude=tmp --exclude=vendor *
endfunction
command! -nargs=0 RebuildTagsFile call s:RebuildTagsFile()

" * Load external config
runtime! custom/statusbar_config.vim
runtime! custom/ruby_and_rails_config.vim
" runtime! custom/clojure_config.vim
runtime! custom/vimshell_config.vim
runtime! custom/taglist_config.vim
runtime! custom/search_config.vim
runtime! custom/nerdcommenter_config.vim
runtime! custom/nerdtree_config.vim
runtime! custom/fuzzy_finder_config.vim



set history=1000
set textwidth=178
set linebreak
set nobackup

set incsearch
  set modeline          " Allow the last line to be a modeline - useful when
                        " the last line in sig gives the preferred textwidth 
                        " for replies.
  set modelines=3
  set mousemodel=popup_setpos  " instead on extend
  set laststatus=2      " show status line?  Yes, always!
                        " Even for only one buffer.
  set showtabline=2
  set nolazyredraw        " [VIM5];  do not update screen while executing macros
  set magic             " Use some magic in search patterns?  Certainly!
                        " the last line in sig gives the preferred textwidth 
                        " for replies.
  set mousemodel=popup  " instead on extend
  set whichwrap=b,s,h,l,<,>,[,]
  set shortmess=atI
  set nostartofline
  set wildchar=<TAB>    " the char used for "expansion" on the command line
                        " default value is "<C-E>" but I prefer the tab key:
  set wildignore=*.bak,*.swp,*.o,*~,*.class,*.exe,*.obj,*.a
  set wildmenu          " Completion on th command line shows a menu
  set winminheight=0	" Minimum height of VIM's windows opened
  set wrapmargin=1    
  set showcmd           " Show current uncompleted command?  Absolutely!
  set suffixes=.bak,.swp,.o,~,.class,.exe,.obj,.a
                        " Suffixes to ignore in file completion, see wildignore
  set switchbuf=useopen,split " test!
 
  let g:tex_flavor = 'latex'
source $HOME/.vim/macros/let-modeline.vim
" Loads FirstModeLine() {{{
if !exists('*FirstModeLine')
  runtime macros/let-modeline.vim
endif
if exists('*FirstModeLine')
  augroup ALL
    au!
    " To not interfer with Templates loaders
    au BufNewFile * :let b:this_is_new_buffer=1
    " Modeline interpretation
    au BufEnter   * :call FirstModeLine()
  augroup END
endif
" }}}
" use ghc functionality for haskell files
" au Bufenter *.hs compiler0 
let g:haddock_browser = "open"
let g:haddock_browser_callformat = "%s %s"
let g:haddock_docdir = "/usr/local/share/doc"     

set mouse=a


function! CopyToPb()
  let text=getreg('z')
  call system('pbcopy', text)
  call system("pbpaste | xsel -i -b")
  return
endfunction

function! PasteFromPb()
  return system('pbpaste')
endfunction

set <Up>=OA
set <Down>=OB
set <Left>=OD
set <Right>=OC
set <PageUp>=[5~
set <PageDown>=[6~
set <Home>=[28~
set <End>=[3~
set <BackSpace>=
set <Delete>=[3~

let g:vimrplugin_underscore = 1
let g:sh_maxlines = 500




if has("autocmd")
    au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$") | exe("norm '\"")|else|exe "norm $"|endif|endif
    au BufWritePost *.sh    !chmod +x %
    au BufWritePost *.pl    !chmod +x %
    au BufWritePost *.zsh   !chmod +x %
    au BufNewFile *.hs      call HaskellHeader()
    au BufNewFile *.R       call InsertSkeleton()
    au BufReadPost *.hs     set omnifunc=haskellcomplete#CompleteHaskell
    au BufReadPost *.hs     imap <S-Tab> <C-x><C-o>
    au BufReadPost *.hs     inoremap <Tab> <C-n>
    au BufReadPost *.hs     let g:SuperTabDefaultCompletionType = "<C-n>"
    au BufReadPost *.lhs    set omnifunc=haskellcomplete#CompleteHaskell
    au BufReadPost *.lhs    imap <S-Tab> <C-x><C-o>
    au BufNewFile *.zsh     call InsertSkeleton()
    au BufNewFile *.sql     call InsertSkeleton()
    au! Bufread,BufNewFile *.pdc    set ft=pdc
    au BufNewFile *.c       call InsertSkeleton()
    au BufNewFile *.c       perldo s/_ (\w*) _ (\w*) _/_$1_$2_/g
    au BufNewFile,BufRead *.rb      inoremap <S-Tab> <Tab>
    au BufNewFile,BufRead *.rb      inoremap <Tab> <C-n>
    au BufNewFile,BufRead *.rb      set ft=ruby
    au BufNewFile,BufRead *.rb      set shiftwidth=2 softtabstop=2
    au BufRead,BufNewFile *.js      inoremap <S-Tab> <Tab>
    au BufNewFile,BufRead *.js      inoremap <Tab> <C-n>
    au BufNewFile,BufRead *.js      set syntax=javascript-mustache shiftwidth=2 softtabstop=2
    au BufNewFile,BufRead *.vim     inoremap <S-Tab> <Tab>
    au BufNewFile,BufRead *.vim     inoremap <Tab> <C-n>
    au BufRead,BufNewFile *.html    set shiftwidth=2 softtabstop=2
    au BufRead,BufNewFile *.zsh     set shiftwidth=2 softtabstop=2
endif


function! HaskellHeader()
    let modname = substitute( expand("%:t"), ".hs", "", "")
    let createdate = substitute( system("date +%D"), "\n", "", "")
    set paste
    let headerStringList = ['-----------------------------------------------------------------------------',
                \ '-- Module      : ' . modname ,
                \ '-- Copyright   : (c) 2010 David M. Rosenberg',
                \ '-- License     : BSD3',
                \ '-- ',
                \ '-- Maintainer  : David Rosenberg <rosenbergdm@uchicago.edu>',
                \ '-- Stability   : experimental',
                \ '-- Portability : portable',
                \ '-- Created     : ' . createdate,
                \ '-- ',
                \ '-- Description :',
                \ '--    DESCRIPTION HERE.',
                \ '-----------------------------------------------------------------------------' ]
    let headerString = join(headerStringList, "\n") . "\n\n"
    execute "normal! i" . headerString
    set nopaste
endfunction

function! RHeader()
    set paste
    let headerStringList = ['#!/usr/bin/env R',
                \ '#===============================================================================',
                \ '#',
                \ '#         FILE:  ' . expand("%"),
                \ '#',
                \ '#        USAGE:  ---',
                \ '#',
                \ '#  DESCRIPTION:  ---',
                \ '#',
                \ '#      OPTIONS:  ---',
                \ '# REQUIREMENTS:  ---',
                \ '#         BUGS:  ---',
                \ '#        NOTES:  ---',
                \ '#       AUTHOR:  David M. Rosenberg <rosenbergdm@uchicago.edu>',
                \ '#      COMPANY:  University of Chicago',
                \ '#      VERSION:  1.0',
                \ '#      CREATED:  ' . strftime("%D"),
                \ '#     REVISION:  ---',
                \ '#===============================================================================' ]
    let headerString = join(headerStringList, "\n") . "\n\n"
    execute "normal! i" . headerString
    set nopaste
endfunction

function! InsertSkeleton()
    let skelType = expand("%:e")
    if filereadable($HOME . '/.vim/skeleton/' . skelType . '-skeleton')
        let rawtext = join(readfile($HOME . '/.vim/skeleton/' . skelType . '-skeleton'), "\n")
        while matchstr(rawtext, '__\(.\{-\}\)__') != ""
            let rawExpr = matchstr(rawtext, '__\(.\{-\}\)__')
            if rawExpr == ""
                break
            endif
            let parsedExpr = substitute(rawExpr, '__', '', 'g')
            let newExpr = eval(parsedExpr)
            let rawtext = substitute(rawtext, rawExpr, newExpr, '')
        endwhile
        let oldpaste=&paste
        set paste
        execute "normal! i" . rawtext
        if oldpaste == 0
            set paste
        endif
    endif
endfunction


" {{{ Folding control
set foldenable
set foldmethod=marker   " Automatically fold stuff
set foldopen=hor,mark,search,block,tag,undo     " Automatically unfold on these events
set foldclose=all       " Automatically close folds when moving out of them    
" }}}

" Use antiword to read word files
autocmd BufReadPre *.doc set ro
autocmd BufReadPre *.doc set hlsearch!
autocmd BufReadPost *.doc %!antiword "%"


" Easy / Better pasting
function! SmartPasteSelection(insertMode)
  let s:old_col = col(".")
  let s:old_lnum = line(".")
  " Correct the cursor position
  if a:insertMode
    if s:old_col == 1
      exec "normal iX\<Esc>"
    else
      exec "normal aX\<Esc>"
    endif
  endif
  exec 'normal "+gP'
  if a:insertMode
    exec 'normal x'
  endif
  let s:after_col = col(".")
  let s:after_col_end=col("$")
  let s:after_col_offset=s:after_col_end-s:after_col
  let s:after_lnum = line(".")
  let s:cmd_str='normal V'
  if s:old_lnum < s:after_lnum
    let s:cmd_str=s:cmd_str . (s:after_lnum - s:old_lnum) . "k"
  elseif s:old_lnum> s:after_lnum
    let s:cmd_str=s:cmd_str . (s:old_lnum - s:after_lnum) . "j"
  endif
  let s:cmd_str=s:cmd_str . "="
  exec s:cmd_str
  let s:new_col_end=col("$")
  call cursor(s:after_lnum, s:new_col_end-s:after_col_offset)
  if a:insertMode
    if s:after_col_offset <=1
      exec 'startinsert!'
    else
      exec 'startinsert'
    endif
  endif
endfunction
nmap <C-V> :call SmartPasteSelection(0)<CR>
imap <C-V> <Esc>:call SmartPasteSelection(1)<CR>


function! HTMLEncode()
perl << EOF
 use HTML::Entities;
 @pos = $curwin->Cursor();
 $line = $curbuf->Get($pos[0]);
 $encvalue = encode_entities($line);
 $curbuf->Set($pos[0],$encvalue)
EOF
endfunction

function! HTMLDecode()
perl << EOF
 use HTML::Entities;
 @pos = $curwin->Cursor();
 $line = $curbuf->Get($pos[0]);
 $encvalue = decode_entities($line);
 $curbuf->Set($pos[0],$encvalue)
EOF
endfunction


let g:persistentBehaviour = 0

set nohlsearch

command -nargs=0 Tmake !pdflatex -interaction=nonstopmode %
command -nargs=0 Tview !xpdf %:s?tex?pdf?:p


function! PrintFile(fname)
  call system("a2ps" . a:fname)
endf


function! SetPrintingPdfType()
  set printdevice=pdf
  set printexpr=PrintFile(v:fname_in)
endfunction

imap <Tab> <C-n>


autocmd FileType python compiler pylint



"   Above is realized with :Pylint command. To disable calling Pylint every
"   time a buffer is saved put into .vimrc file
"
"       let g:pylint_onwrite = 0
"
"   Displaying code rate calculated by Pylint can be avoided by setting
"
"       let g:pylint_show_rate = 0
"
"   Openning of QuickFix window can be disabled with
"
"       let g:pylint_cwindow = 0
"
"   Of course, standard :make command can be used as in case of every
"   other compiler.
