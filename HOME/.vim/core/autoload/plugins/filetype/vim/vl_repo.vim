" Both the FixPrefixesOfAutoloadFunctions command and mapping are experimental 
" For example it tries to fx' fun!  dict.Name() which is wrong
" However you can always just use undo..

function! plugins#filetype#vim#vl_repo#PluginVL_RepoStuff(p)
  let p = a:p
  let p['Tags'] = ['filetype','vimscript']
  let p['Info'] = "user completion, goto thing on cursor and fix function prefixes"

  let p['defaults']['tags_buftype'] = {'vim' : ['vim']}
  let p['defaults']['tags'] = ['vim']
  " run this to fix prefixes of autoload functions (remember that you can use undo.. :-)
  let p['feat_mapping'] = {
    \ 'fix_function_prefixes' : {
      \ 'lhs' : '<m-f><m-p>',
      \ 'rhs' : ':call tovl#ft#vimscript#vimfile#FixPrefixesOfAutoloadFunctions()<cr>' }}
  let p['feat_command'] = {
    \ 'fix_function_prefixes' : {
      \ 'name' : 'FixPrefixesOfAutoloadFunctions',
      \ 'attrs' : '-nargs=0',
      \ 'cmd' : ':call tovl#ft#vimscript#vimfile#FixPrefixesOfAutoloadFunctions()<cr>' }}


  " completion
  let p['feat_completion_func'] = {
    \ 'register_completion_func' : {
      \ 'description' : 'vim funtion completion based on ScanAndCache scanned .vim files found in &runtimepath',
      \ 'completion_func' : library#Function('tovl#ft#vimscript#vimfile#CompleteFunction')}
    \ }

  " command
  let p['autocommands']['fix_prefixes_cmd'] = {
      \ 'events' : 'FileType',
      \ 'pattern' : 'vim',
      \ 'cmd' : "command! -buffer -nargs=0 FixPrefixesOfAutoloadFunctions :call tovl#ft#vimscript#vimfile#FixPrefixesOfAutoloadFunctions()<cr>"
    \ }


  let child = {}
  fun! child.Load()
    call on_thing_handler#AddOnThingHandler('g', funcref#Function('tovl#ft#vimscript#vimfile#GetFuncLocation', {'args' : [1]}))

    call self.Parent_Load()
  endf

  return  p.createChildClass(child)
endfunction
