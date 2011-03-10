
" author: Marc Weber
"
" You still want to get the completion and syntax code from their website
"
function! plugins#filetype#haxe#PluginHaxe(p)
  let p = a:p
  let p['Tags'] = ["haxe"]
  let p['Info'] = "This plugins runs a syntax checker after writing the file"

  let p['defaults']['filetypes'] = {}
  let p['defaults']['tags'] = ['haxe']

  let p['feat_command'] = {
      \ 'haxe_set_build_hxml' : {
          \ 'name' : 'HaxeSetBuildXML',
          \ 'attrs' : '-nargs=1 -complete=file',
          \ 'cmd' : 'call '.p.s.'.SetBuildXml(<q-args>)'
      \ },
    \ }

  fun! p.SetBuildXml(hxml_file)
    let g:haxe_build_hxml = a:hxml_file
  endf

  fun! p.Check()
    call self.FindHaxe()
  endf

  function! p.DefineHXMLFile()
    if !exists('g:haxe_build_hxml')
      let files = split(glob('*.hxml'),"\n")
      if len(files) > 0
        let g:haxe_build_hxml = tovl#ui#choice#LetUserSelectIfThereIsAChoice("found the following .hxml files:", files)
      else
        echoe "no .hxml found!"
      endif
    endif
  endfunction

  fun! p.RunHaxeActionString()
    call self.DefineHXMLFile()
    return 'silent! wa <bar>'
          \ . 'call tovl#runtaskinbackground#Run('.string({'cmd': ["haxe", g:haxe_build_hxml],
                                                          \ 'ef' : 'plugins#tovl#errorformats#PluginErrorFormats#haxe', 'onFinishCallbacks' : ['cope']}).')'
  endf
  let p['feat_action'] = {
        \ 'run_haxe' : {
        \   'key': 'run_haxe',
        \   'description': "runs haxe <this file> and loads the result into the quickfix window",
        \   'action' : library#Function('return '. p.s .'.RunHaxeActionString()')
        \ }}
  return p

  let child = {}
  fun! child.Load()
    let g:HighlightCurrentLine=0
    for k in keys(self.cfg.filetypes)
      if !get(self.cfg.filetypes[k],'active',0)
        continue
      endif
      let v = self.cfg.filetypes[k]
      try
        call self.Au({'events': 'bufwritepost', 'pattern': v.pattern,
              \ 'cmd': "silent! call tovl#runtaskinbackground#NewProcess( "
              \         ."{ 'name' : 'syntax_checker_plugin', 'cmd': ".string(v.cmd).", 'ef' : ".string(v.ef).", 'fg' : ".(!get(v,'background',0)).", 'expectedExitCode' : '*' }).Run()"})
      catch /.*/
        call self.Log(0, 'exception while setting up syntax check for '.k)
      endtry
    endfor
    call self.Parent_Load()
  endf
  return p.createChildClass(child)
endfunction
