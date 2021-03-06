" see also PluginSyntaxChecker
function! plugins#filetype#nix#PluginNixSupport(p)
  let p = a:p
  let p['Tags'] = ["nix"]
  let p['Info'] = "small nix features"
  let p['defaults']['tags'] = ['nix_support']
  let p['defaults']['tags_buftype'] = {'nix' : ['nix_support']}

  " mappings to evaluate contents of current buffer using nix-instantiate
  let p['feat_mapping'] = {
      \ 'eval' : {
        \ 'lhs' : '<F2>',
        \ 'buffer' : 1,
        \ 'rhs' : ':call '.p.s.'.Run(0)<cr>' },
      \ 'eval_xml' : {
        \ 'buffer' : 1,
        \ 'lhs' : '<F3>',
        \ 'rhs' : ':call '.p.s.'.Run(1)<cr>' }}

  let p['feat_command'] = {
    \ 'load_errors_from_buffer_into_quickfix' : {
      \ 'name' : 'NixErrorsFromBufferToQuickfix',
      \ 'cmd' : 'call tovl#errorformat#SetErrorFormat("plugins#tovl#errorformats#PluginErrorFormats#nix") | cbuffer',
      \ 'attrs' : '-nargs=0',
      \ }
    \ }

  fun! p.LocationList()

    let res = [
      \   expand(expand('%:h').'/'.matchstr(expand('<cWORD>'),'[^;()[\]]*')),
      \   expand('%:h').'/'.matchstr(getline('.'), 'import\s*\zs[^;) \t]\+\ze')
      \ ]

    " if import string is a directory append '/default.nix' :
    call map(res, 'v:val =~ '.string('\.nix').' ? v:val : v:val.'.string('/default.nix'))

    let list = matchlist(getline('.'), '.*selectVersion\s\+\(\S*\)\s\+"\([^"]\+\)"')
    if (!empty(list))
      " something like this has been matched selectVersion ../applications/version-management/codeville "0.8.0"
      call add(res, expand('%:h').'/'.list[1].'/'.list[2].'.nix')
    else
      " something with var instead of "0.8.x" has been matched
      let list = matchlist(getline('.'), '.*selectVersion\s\+\(\S*\)\s\+\(\S\+\)')
      if (!empty(list))
        call extend(res, split(glob(expand('%:h').'/'.list[1].'/*.nix'), "\n"))
        " also add subdirectory files (there won't be that many)
        call extend(res, filter(split(glob(expand('%:h').'/'.list[1].'/*/*.nix'), "\n"),'1'))
      endif
    endif
    return res
  endf
  fun! p.Run(xml)
    update
    let cmd = tovl#runtaskinbackground#NewProcess({ 'name' : 'nix-instantiate',
          \ 'cmd' : ['nix-instantiate', '--eval-only', '--show-trace', '--strict'] + ( a:xml ? ["--xml"] : []) +  [library#Function('return expand("%")') ],
          \ 'ef' : 'plugins#tovl#errorformats#PluginErrorFormats#nix',
          \ 'onFinishCallbacks' : (a:xml ? ["cope"] : ["cope"])}
          \ )
    call cmd.Run()
  endf

  let child = {}
  fun! child.Load()
    call on_thing_handler#AddOnThingHandler('g', funcref#Function("return ". self.s .".LocationList()")) 
    call self.Parent_Load()
  endf

  return  p.createChildClass(child)
endfunction


" Fix imports

"let g:cache=split(glob('**'),"\n")

"let g:vim_fix_nix_dict = {}

"[> build up dict containing list (we allow multiple directroies ending the same
"[> way)
"for i in g:cache
"  let lastPathComponent = fnamemodify(i, ":t")
"  let g:vim_fix_nix_dict[lastPathComponent] = get(g:vim_fix_nix_dict, lastPathComponent, [])
"  call add(g:vim_fix_nix_dict[lastPathComponent], i)
"endfor

"fun! FixNext()
"  set cul
"  [> assuming paths don't contain spaces..
"  call search('import\s\+"\?','e')
"  normal lvE

"  [> check wether last char is either " or )
"  [> this won't work for unicode chars.. I don't mind here
"  let char = getline(line('.'))[col('.')-1]
"  if char == ')' || char == '"'
"    normal h
"  endif
"  [> copy selection
"  normal y
"  let path = @[>

"  let abs_path = getcwd().'/'.expand('%:h').'/'.path
"  if (!isdirectory(abs_path) && !filereadable(abs_path))
"    let last = fnamemodify(abs_path, ":t")
"    let found = get(g:vim_fix_nix_dict, last, [])
"    if empty(found)
"      echo "no matches found"
"    else
"      let x = tovl#ui#choice#LetUserSelectIfThereIsAChoice('select match for '.path, found)
"      let relative =  substitute(tlib#file#Relative(x, expand('%:h')),'/$','','')
"      [> prepend ./
"      let relative = substitute(relative,'^\([^.]\)','./\1','')
"      normal jjjzbkkk
"      redraw
"      echo 'replace '.path.' by '.relative.' ? [y]'
"      if nr2char(getchar()) == 'y'
"        exec 'silent! normal gvs'.relative
"      endif
"    endif
"  else
"    [> does exist, search next
"    call FixNext()
"  endif
"endf

"command! FixNext call FixNext()
"noremap <F6> :FixNext<cr>
"
"
"fun! Test()
"  let d = {}
"  for i in getline(1,line('$'))
"    let m = matchlist(i, '^  \s*\(\S*\)\s*=\s*import\s*../\(\S*\).*')
"    if empty(m)
"      continue
"    endif
"    let m2 = matchstr(m[2], '\zs.*/\ze.*$')
"    if empty(m)
"      echo m
"      echo i
"    else
"      let l = get(d, m2, [])
"      call add(l, m[1])
"      let d[m2] = l
"    endif
"  endfor
"  let final = []
"  for [k,l] in items(d)
"    call add(final, k)
"    for lin in l
"      call add(final, '   '.lin)
"    endfor
"  endfor
"  put=final
"endf
"call Test()

