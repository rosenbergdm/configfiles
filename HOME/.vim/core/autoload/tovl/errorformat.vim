" Gets an error format from the configuration
" see  also autoload/plugins/tovl/error_formats.vim

fun! tovl#errorformat#SetErrorFormat(id)
  let match = matchstr(a:id,'string:\zs.*')
  if match != ''
    exec 'silent! set efm='.match
  else
    exec 'silent! set efm='.join(map(split(
          \ config#Get(a:id),"\n")
          \ , 'tovl#errorformat#EscapePattern(v:val)'),',')
  endif
endf

function! tovl#errorformat#EscapePattern(p)
  return escape(substitute(a:p,',','\\,','g'),' \,|"')
endfunction
