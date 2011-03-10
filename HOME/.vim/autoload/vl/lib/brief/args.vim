"|fld   description : get additional args
"|fld   keywords : "shorten vimscript" 
"|fld   initial author : Marc Weber marco-oweber@gmx.de
"|fld   mantainer : author
"|fld   started on : 2006 Nov 06 21:31:32
"|fld   version: 0.0
"|fld   contributors : <+credits to+>
"|fld   tested on os : <+credits to+>
"|fld   maturity: stable
"|
"|H1__  Documentation
"|

"|p     returns optional argument or default value
"|p     Example usage:
"|code  function! F(...)
"|        exec GetOptionalArg('optional_arg',string('no optional arg given'))
"|        echo 'optional arg is '.string(optional_arg)
"|      endfunction
function! vl#lib#brief#args#GetOptionalArg( name, default)
  if type( a:default) != 1
    throw "wrong type: default parameter of vl#lib#brief#args#GetOptionalArg must be a string, use string(value)"
  endif
  let script = [ "if a:0 > 0"
	     \ , "  let ".a:name." = a:1"
	     \ , "else"
	     \ , "  let ".a:name." = ".a:default
	     \ , "endif"
	     \ ]
  return join( script, "\n")
endfunction
