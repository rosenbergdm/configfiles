augroup filetypedetect
  au! BufRead,BufNewFile *.r        setfiletype r
  au! BufRead,BufNewFile *.R        setfiletype r
  au! BufRead,BufNewFile *.Rnw      setf noweb
  " au! BufRead,BufNewFile *.hs       set omnifunc=haskellcomplete#CompleteHaskell
  " au! BufRead,BufNewFile *.lhs      set omnifunc=haskellcomplete#CompleteHaskell
  au! BufRead,BufNewFile *.fmt      setf tex
  au! BufRead,BufNewFile *.rb       set shiftwidth=2 softtabstop=2
  au! BufRead,BufNewFile *.js       set shiftwidth=2 softtabstop=2
  au! BufRead,BufNewFile *.json     set shiftwidth=2 softtabstop=2
  " au! BufRead,BufNewFile *.mustache.* set syntax=mustache shiftwidth=2 softtabstop=2
augroup END



