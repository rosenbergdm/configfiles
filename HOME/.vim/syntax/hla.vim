" Vim syntax file
" Language:     High Level Assembler (HLA)
" Orig Author:  Jan Tatham <jan@vistainsight.com>
" Last Change:  $Date: 2007/04/21 13:20:15 $
" $Revision:    0.01 $

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case ignore


syn match hlaIdentifier     "[@a-z_$?][@a-z0-9_$?]*"
" syn match hlaLabel          "^\s*[@a-z_$?][@a-z0-9_$?]*:"he=e-1

syn match hlaDecimal        "[-+]\?\d\+[dt]\?"
syn match hlaBinary         "[-+]\?[0-1]\+[by]"  "put this before hex or 0bfh dies!
syn match hlaOctal          "[-+]\?[0-7]\+[oq]"
syn match hlaHexadecimal    "[-+]\?[0-9]\x*h"
syn match hlaFloatRaw       "[-+]\?[0-9]\x*r"
syn match hlaFloat          "[-+]\?\d\+\.\(\d*\(E[-+]\?\d\+\)\?\)\?"

syn match hlaComment        "//.*" contains=@Spell
syn region hlaComment       start=+COMMENT\s*\z(\S\)+ end=+\z1.*+ contains=@Spell
syn region hlaString        start=+'+ end=+'+ oneline contains=@Spell
syn region hlaString        start=+"+ end=+"+ oneline contains=@Spell

syn region hlaTitleArea     start=+\<TITLE\s+lc=5 start=+\<SUBTITLE\s+lc=8 start=+\<SUBTTL\s+lc=6 end=+$+ end=+;+me=e-1 contains=hlaTitle
syn region hlaTextArea      start=+\<NAME\s+lc=4 start=+\<INCLUDE\s+lc=7 start=+\<INCLUDELIB\s+lc=10 end=+$+ end=+;+me=e-1 contains=hlaText
syn match hlaTitle          "[^\t ;]\([^;]*[^\t ;]\)\?" contained contains=@Spell
syn match hlaText           "[^\t ;]\([^;]*[^\t ;]\)\?" contained

syn region hlaOptionOpt     start=+\<OPTION\s+lc=6 end=+$+ end=+;+me=e-1 contains=hlaOption
syn region hlaContextOpt    start=+\<PUSHCONTEXT\s+lc=11 start=+\<POPCONTEXT\s+lc=10 end=+$+ end=+;+me=e-1 contains=hlaOption
syn region hlaModelOpt      start=+\.MODEL\s+lc=6 end=+$+ end=+;+me=e-1 contains=hlaOption,hlaType
syn region hlaSegmentOp     start=+\<SEGMENT\s+lc=7 end=+$+ end=+;+me=e-1 contains=hlaOption,hlaString
syn region hlaProcOpt       start=+\<PROC\s+lc=4 end=+$+ end=+;+me=e-1 contains=hlaOption,hlaType,hlaRegister,hlaIdentifier
syn region hlaAssumeOpt     start=+\<ASSUME\s+lc=6 end=+$+ end=+;+me=e-1 contains=hlaOption,hlaOperator,hlaType,hlaRegister,hlaIdentifier
syn region hlaExpression    start=+\.IF\s+lc=3 start=+\.WHILE\s+lc=6 start=+\.UNTIL\s+lc=6 start=+\<IF\s+lc=2 start=+\<IF2\s+lc=3 start=+\<ELSEIF\s+lc=6      start=+\<ELSEIF2\s+lc=7 start=+\<REPEAT\s+lc=6 start=+\<WHILE\s+lc=5 end=+$+ end=+;+me=e-1 contains=hlaType,hlaOperator,hlaRegister,hlaIdentifier,hlaDecimal,hlaBinary,hlaHexadecimal,hlaFloatRaw,hlaString

syn keyword hlaBoolean      TRUE FALSE
syn match   hlaBoolean      "@C"
syn match   hlaBoolean      "@NC"
syn match   hlaBoolean      "@Z"
syn match   hlaBoolean      "@NZ"
syn match   hlaBoolean      "@O"
syn match   hlaBoolean      "@NO"
syn match   hlaBoolean      "@S"
syn match   hlaBoolean      "@NS"

syn match hlaOption         "\#INCLUDE\>"
syn match hlaOption         "\#INCLUDEONCE\>"

syn keyword hlaType         STDCALL SYSCALL C BASIC FORTRAN PASCAL
syn keyword hlaType         INT8 INT16 INT32 UNS8 UNS16 UNS32
syn keyword hlaType         REAL32 REAL64 REAL80
syn keyword hlaType         BOOLEAN BYTE CHAR DWORD STRING WORD


syn keyword hlaPreProc      IF THEN DO ELSE ELSEIF REPEAT UNTIL
syn keyword hlaPreProc      END ENDIF TRY EXCEPTION ENDTRY WHILE ENDWHILE
syn keyword hlaPreProc      FOR ENDFOR FOREVER BREAK BREAKIF

syn keyword hlaRegister     AX BX CX DX SI DI BP SP
syn keyword hlaRegister     CS DS SS ES FS GS
syn keyword hlaRegister     AH BH CH DH AL BL CL DL
syn keyword hlaRegister     EAX EBX ECX EDX ESI EDI EBP ESP

syn keyword hlaOpcode       ADD SUB INC DEC LEA NEG
syn keyword hlaOpCode       MOV MOVSX PUSH POP
syn keyword hlaOpCode       AND NOT OR XOR SHL SHR SAR ROL ROR RCL RCR
syn keyword hlaOpcode       CBW CWD CDQ CWDE
syn keyword hlaOpcode       MALLOC FREE

syn keyword hlaConditional  CLD STD CLI STI CLC STC CMC SAHF LAHF         

syn keyword hlaStatement    STDOUT STDIN NL NEWLN READLN
syn keyword hlaStatement    GET GETB GETC GETD GETF GETW PUT PUTB PUTC PUTD PUTW
syn keyword hlaStatement    PUTI8 PUTI16 PUTI32 PUTI8SIZE PUTI16SIZE PUTI32SIZE
syn keyword hlaStatement    PUTCSIZE
syn keyword hlaStatement    PUTR32 PUTR64 PUTR80 PUTE32 PUTE64 PUTE80
syn keyword hlaStatement    GETI8 GETI16 GETI32
syn keyword hlaStatement    FLUSHINPUT

syn keyword hlaTitle        PROGRAM STATIC ENDSTATIC BEGIN END PROCEDURE
syn keyword hlaTitle        TYPE ENDTYPE CONST ENDCONST READONLY ENDREADONLY
syn keyword hlaTitle        STORAGE ENDSTORAGE

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_hla_syntax_inits")
  if version < 508
    let did_hla_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default methods for highlighting.  Can be overridden later
  HiLink hlaBoolean     Boolean
  HiLink hlaConditional Conditional
  HiLink hlaLabel       PreProc
  HiLink hlaPreProc     PreProc
  HiLink hlaComment     Comment
  HiLink hlaDirective   Statement
  HiLink hlaFunction    Function
  HiLink hlaType        Type
  HiLink hlaOperator    Type
  HiLink hlaOption      Special
  HiLink hlaRegister    Special
  HiLink hlaStatement   Statement
  HiLink hlaString      String
  HiLink hlaText        String
  HiLink hlaTitle       Title
  HiLink hlaOpcode      PrePoc
  HiLink hlaOpFloat     Statement

  HiLink hlaHexadecimal Number
  HiLink hlaDecimal     Number
  HiLink hlaOctal       Number
  HiLink hlaBinary      Number
  HiLink hlaFloatRaw    Number
  HiLink hlaFloat       Number

  HiLink hlaIdentifier Identifier

  syntax sync minlines=50

  delcommand HiLink
endif

let b:current_syntax = "hla"

" vim: ts=8
