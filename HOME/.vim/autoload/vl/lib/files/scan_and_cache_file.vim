"|fld   description : Get some content from file and cache it.
"|fld   keywords : cache, filecontent 
"|fld   initial author : Marc Weber marco-oweber@gmx.de
"|fld   mantainer : author
"|fld   started on : 2006 Oct 03 13:22:17
"|fld   version: 0.0
"|fld   maturity: tested on linux and windows
"|
"|doc   
"|H1__  Documentation
"|
"|p     Use
"|code  let scan_result = ScanIfNewer('<file_path>','<scan_func>')
"|p     this will return the scanned file or the cached previous value
"|
"|H2_   Known problems: If two scripts want to use ScanIfNewer only the last
"|+     value will be kept
"|
"|H2_   Examples:
"|      See autoload/vl/dev/vimscript/vimfile.vim function ScanVimFile
"|
"|set   
"|      " set s:cache_results to 1 to cache scanned results in files located
"|        in s:cache_dir
let s:cache_results=vl#lib#vimscript#scriptsettings#Load(
  \ 'vl.lib.files.scan_and_cache_file.cache_results', 1)
let s:cache_dir=vl#lib#vimscript#scriptsettings#Load(
  \ 'vl.lib.files.scan_and_cache_file.cache_dir',
 \ vl#settings#DotvimDir().'scan_and_cache_file_cache')
"|
"|pl    " clear cache
"|      command! ClearScanAndCacheFileCache :call ClearScanAndCacheFileCache()
"|TODO add command to clear cache.. because it will grow and grow.

"|func  scans the file using given function if it hasn't been scanned yet returns
"|      result of this scan or previous scan.
"|      scan_func takes the file as line list ( readfile ) and should return the
"|+     scanned file info
function! vl#lib#files#scan_and_cache_file#ScanIfNewer(file, scan_func,...)
  exec vl#lib#brief#args#GetOptionalArg("cache",string("1"))
  let file = expand(a:file)
  let func_as_string = string(a:scan_func)
  if !exists('g:scanned_files')
    let g:scanned_files = {}
  endif
  if !vl#lib#listdict#dict#HasKey(g:scanned_files, func_as_string)
    let g:scanned_files[func_as_string] = {}
  endif
  let dict = g:scanned_files[func_as_string]
  if s:cache_results
    let cache_file = expand(s:cache_dir.'/'.s:CacheFileName(a:scan_func, a:file))
    if !vl#lib#listdict#dict#HasKey(dict, a:file) " try getting from cache
      if filereadable(cache_file)
	let dict[file] = eval(readfile(cache_file)[0])
      endif
    endif
  endif
  if vl#lib#listdict#dict#HasKey(dict, a:file)
    " return cached value if up to date
    if getftime(a:file) <= dict[a:file]['ftime']
      return dict[a:file]['scan_result']
    endif
  endif
  let scan_result = a:scan_func(readfile(a:file))
  "echo "scanning ".a:file
  let  dict[a:file] = {"ftime": getftime(a:file), "scan_result": scan_result }
  if s:cache_results && cache
    call vl#lib#files#filefunctions#WriteFile([string(dict[a:file])], cache_file)
  endif
  return scan_result
endfunction

function! s:CacheFileName(scan_func, file)
  return vl#lib#files#filefunctions#FileHashValue(string(a:scan_func).a:file)
endfunction

function! vl#lib#files#scan_and_cache_file#ClearScanAndCacheFileCache()
  call vl#lib#files#filefunctions#RemoveDirectoryRecursively(s:cache_dir)
  unlet g:scanned_files
endfunction

" only saves file content
function! vl#lib#files#scan_and_cache_file#ScanFileContent(file_lines)
  return a:file_lines
endfunction

if !isdirectory(s:cache_dir)
  echoe "error in ".expand("<sfile>")." you have to create temporary directory ".s:cache_dir
endif
