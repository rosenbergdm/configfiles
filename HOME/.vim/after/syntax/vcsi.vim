" Vim additional syntax: vcsi - Version Control System Interface
" Version: 0.1.0
" Copyright (C) 2007-2008 kana <http://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}




syntax region vcsiLog keepend start=/^\%^/ end=/^=== .* ===$/me=s-1
syntax match vcsiLongTitle /^.\{50}\zs.*$/ containedin=vcsiSummary
syntax match vcsiSeparator /^=== .* ===$/
syntax match vcsiSummary /^\%1l.*$/ containedin=vcsiLog




highlight default link vcsiLog Normal
highlight default link vcsiLongTitle Error
highlight default link vcsiSeparator Delimiter
highlight default link vcsiSummary Statement




" __END__
" vim: foldmethod=marker
