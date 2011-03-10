" Vim syntax file
" Language:     sqlite
" Maintainer:   
" Last Change: Mon May 03 12:00 PM 2010 C
" Filenames:    
" URL:          
" Note:         

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Always ignore case
syn case ignore

" General keywords which don't fall into other categories
syn keyword sqliteKeyword         action add after aggregate all alter as asc auto_increment avg avg_row_length
syn keyword sqliteKeyword         both by
syn keyword sqliteKeyword         cascade change character check checksum column columns comment constraint create cross
syn keyword sqliteKeyword         current_date current_time current_timestamp
syn keyword sqliteKeyword         data database databases day day_hour day_minute day_second
syn keyword sqliteKeyword         default delayed delay_key_write delete desc describe distinct distinctrow drop
syn keyword sqliteKeyword         enclosed escape escaped explain
syn keyword sqliteKeyword         fields file first flush for foreign from full function
syn keyword sqliteKeyword         global grant grants group
syn keyword sqliteKeyword         having heap high_priority hosts hour hour_minute hour_second
syn keyword sqliteKeyword         identified ignore index infile inner insert insert_id into isam
syn keyword sqliteKeyword         join
syn keyword sqliteKeyword         key keys kill last_insert_id leading left limit lines load local lock logs long 
syn keyword sqliteKeyword         low_priority
syn keyword sqliteKeyword         match max_rows middleint min_rows minute minute_second modify month myisam
syn keyword sqliteKeyword         natural no
syn keyword sqliteKeyword         on optimize option optionally order outer outfile
syn keyword sqliteKeyword         pack_keys partial password primary privileges procedure process processlist
syn keyword sqliteKeyword         read references reload rename replace restrict returns revoke row rows
syn keyword sqliteKeyword         second select show shutdown soname sql_big_result sql_big_selects sql_big_tables sql_log_off
syn keyword sqliteKeyword         sql_log_update sql_low_priority_updates sql_select_limit sql_small_result sql_warnings starting
syn keyword sqliteKeyword         status straight_join string
syn keyword sqliteKeyword         table tables temporary terminated to trailing type
syn keyword sqliteKeyword         unique unlock unsigned update usage use using
syn keyword sqliteKeyword         values varbinary variables varying
syn keyword sqliteKeyword         where with write
syn keyword sqliteKeyword         year_month
syn keyword sqliteKeyword         zerofill
syn keyword sqliteKeyword         autoincrement
syn keyword sqliteMeta           .databases .dump .echo .explain .header .headers .import .indices .mode .nullvalue .output .output .prompt .read .schema .separator .tables .timeout .width



" Special values
syn keyword sqliteSpecial         false null true

" Strings (single- and double-quote)
syn region sqliteString           start=+"+  skip=+\\\\\|\\"+  end=+"+
syn region sqliteString           start=+'+  skip=+\\\\\|\\'+  end=+'+

" Numbers and hexidecimal values
syn match sqliteNumber            "-\=\<[0-9]*\>"
syn match sqliteNumber            "-\=\<[0-9]*\.[0-9]*\>"
syn match sqliteNumber            "-\=\<[0-9]*e[+-]\=[0-9]*\>"
syn match sqliteNumber            "-\=\<[0-9]*\.[0-9]*e[+-]\=[0-9]*\>"
syn match sqliteNumber            "\<0x[abcdefABCDEF0-9]*\>"

" User variables
syn match sqliteVariable          "@\a*[A-Za-z0-9]*[._]*[A-Za-z0-9]*"

" Comments (c-style, sqlite-style and modified sql-style)
syn region sqliteComment          start="/\*"  end="\*/"
syn match sqliteComment           "#.*"
syn match sqliteComment           "--\_s.*"
syn sync ccomment sqliteComment

" Column types
"
" This gets a bit ugly.  There are two different problems we have to
" deal with.
"
" The first problem is that some keywoards like 'float' can be used
" both with and without specifiers, i.e. 'float', 'float(1)' and
" 'float(@var)' are all valid.  We have to account for this and we
" also have to make sure that garbage like floatn or float_(1) is not
" highlighted.
"
" The second problem is that some of these keywords are included in
" function names.  For instance, year() is part of the name of the
" dayofyear() function, and the dec keyword (no parenthesis) is part of
" the name of the decode() function. 

syn keyword sqliteType              INT INTEGER TEXT REAL TEXT BLOB

" syn keyword sqliteType            tinyint smallint mediumint int integer bigint 
" syn keyword sqliteType            date datetime time bit bool 
" syn keyword sqliteType            tinytext mediumtext longtext text
" syn keyword sqliteType            tinyblob mediumblob longblob blob
" syn region sqliteType             start="float\W" end="."me=s-1 
" syn region sqliteType             start="float$" end="."me=s-1 
" syn region sqliteType             start="float(" end=")" contains=sqliteNumber,sqliteVariable
" syn region sqliteType             start="double\W" end="."me=s-1
" syn region sqliteType             start="double$" end="."me=s-1
" syn region sqliteType             start="double(" end=")" contains=sqliteNumber,sqliteVariable
" syn region sqliteType             start="double precision\W" end="."me=s-1
" syn region sqliteType             start="double precision$" end="."me=s-1
" syn region sqliteType             start="double precision(" end=")" contains=sqliteNumber,sqliteVariable
" syn region sqliteType             start="real\W" end="."me=s-1
" syn region sqliteType             start="real$" end="."me=s-1
" syn region sqliteType             start="real(" end=")" contains=sqliteNumber,sqliteVariable
" syn region sqliteType             start="numeric(" end=")" contains=sqliteNumber,sqliteVariable
" syn region sqliteType             start="dec\W" end="."me=s-1
" syn region sqliteType             start="dec$" end="."me=s-1
" syn region sqliteType             start="dec(" end=")" contains=sqliteNumber,sqliteVariable
" syn region sqliteType             start="decimal\W" end="."me=s-1
" syn region sqliteType             start="decimal$" end="."me=s-1
" syn region sqliteType             start="decimal(" end=")" contains=sqliteNumber,sqliteVariable
" syn region sqliteType             start="\Wtimestamp\W" end="."me=s-1
" syn region sqliteType             start="\Wtimestamp$" end="."me=s-1
" syn region sqliteType             start="\Wtimestamp(" end=")" contains=sqliteNumber,sqliteVariable
" syn region sqliteType             start="^timestamp\W" end="."me=s-1
" syn region sqliteType             start="^timestamp$" end="."me=s-1
" syn region sqliteType             start="^timestamp(" end=")" contains=sqliteNumber,sqliteVariable
" syn region sqliteType             start="\Wyear(" end=")" contains=sqliteNumber,sqliteVariable
" syn region sqliteType             start="^year(" end=")" contains=sqliteNumber,sqliteVariable
" syn region sqliteType             start="char(" end=")" contains=sqliteNumber,sqliteVariable
" syn region sqliteType             start="varchar(" end=")" contains=sqliteNumber,sqliteVariable
" syn region sqliteType             start="enum(" end=")" contains=sqliteString,sqliteVariable
" syn region sqliteType             start="\Wset(" end=")" contains=sqliteString,sqliteVariable
" syn region sqliteType             start="^set(" end=")" contains=sqliteString,sqliteVariable
" 
" " Logical, string and  numeric operators
" syn keyword sqliteOperator        between not and or is in like regexp rlike binary exists
" syn region sqliteOperator         start="isnull(" end=")" contains=ALL
" syn region sqliteOperator         start="coalesce(" end=")" contains=ALL
" syn region sqliteOperator         start="interval(" end=")" contains=ALL
" 
" " Control flow functions
" syn keyword sqliteFlow            case when then else end
" syn region sqliteFlow             start="ifnull("   end=")"  contains=ALL
" syn region sqliteFlow             start="nullif("   end=")"  contains=ALL
" syn region sqliteFlow             start="if("       end=")"  contains=ALL
" 
" General Functions
"
" I'm leery of just defining keywords for functions, since according to the MySQL manual:
"
"     Function names do not clash with table or column names. For example, ABS is a 
"     valid column name. The only restriction is that for a function call, no spaces 
"     are allowed between the function name and the `(' that follows it. 
"
" This means that if I want to highlight function names properly, I have to use a 
" region to define them, not just a keyword.  This will probably cause the syntax file 
" to load more slowly, but at least it will be 'correct'.

syn region sqliteFunction         start="abs(" end=")" contains=ALL
syn region sqliteFunction         start="acos(" end=")" contains=ALL
syn region sqliteFunction         start="adddate(" end=")" contains=ALL
syn region sqliteFunction         start="ascii(" end=")" contains=ALL
syn region sqliteFunction         start="asin(" end=")" contains=ALL
syn region sqliteFunction         start="atan(" end=")" contains=ALL
syn region sqliteFunction         start="atan2(" end=")" contains=ALL
syn region sqliteFunction         start="benchmark(" end=")" contains=ALL
syn region sqliteFunction         start="bin(" end=")" contains=ALL
syn region sqliteFunction         start="bit_and(" end=")" contains=ALL
syn region sqliteFunction         start="bit_count(" end=")" contains=ALL
syn region sqliteFunction         start="bit_or(" end=")" contains=ALL
syn region sqliteFunction         start="ceiling(" end=")" contains=ALL
syn region sqliteFunction         start="character_length(" end=")" contains=ALL
syn region sqliteFunction         start="char_length(" end=")" contains=ALL
syn region sqliteFunction         start="concat(" end=")" contains=ALL
syn region sqliteFunction         start="concat_ws(" end=")" contains=ALL
syn region sqliteFunction         start="connection_id(" end=")" contains=ALL
syn region sqliteFunction         start="conv(" end=")" contains=ALL
syn region sqliteFunction         start="cos(" end=")" contains=ALL
syn region sqliteFunction         start="cot(" end=")" contains=ALL
syn region sqliteFunction         start="count(" end=")" contains=ALL
syn region sqliteFunction         start="curdate(" end=")" contains=ALL
syn region sqliteFunction         start="curtime(" end=")" contains=ALL
syn region sqliteFunction         start="date_add(" end=")" contains=ALL
syn region sqliteFunction         start="date_format(" end=")" contains=ALL
syn region sqliteFunction         start="date_sub(" end=")" contains=ALL
syn region sqliteFunction         start="dayname(" end=")" contains=ALL
syn region sqliteFunction         start="dayofmonth(" end=")" contains=ALL
syn region sqliteFunction         start="dayofweek(" end=")" contains=ALL
syn region sqliteFunction         start="dayofyear(" end=")" contains=ALL
syn region sqliteFunction         start="decode(" end=")" contains=ALL
syn region sqliteFunction         start="degrees(" end=")" contains=ALL
syn region sqliteFunction         start="elt(" end=")" contains=ALL
syn region sqliteFunction         start="encode(" end=")" contains=ALL
syn region sqliteFunction         start="encrypt(" end=")" contains=ALL
syn region sqliteFunction         start="exp(" end=")" contains=ALL
syn region sqliteFunction         start="export_set(" end=")" contains=ALL
syn region sqliteFunction         start="extract(" end=")" contains=ALL
syn region sqliteFunction         start="field(" end=")" contains=ALL
syn region sqliteFunction         start="find_in_set(" end=")" contains=ALL
syn region sqliteFunction         start="floor(" end=")" contains=ALL
syn region sqliteFunction         start="format(" end=")" contains=ALL
syn region sqliteFunction         start="from_days(" end=")" contains=ALL
syn region sqliteFunction         start="from_unixtime(" end=")" contains=ALL
syn region sqliteFunction         start="get_lock(" end=")" contains=ALL
syn region sqliteFunction         start="greatest(" end=")" contains=ALL
syn region sqliteFunction         start="group_unique_users(" end=")" contains=ALL
syn region sqliteFunction         start="hex(" end=")" contains=ALL
syn region sqliteFunction         start="inet_aton(" end=")" contains=ALL
syn region sqliteFunction         start="inet_ntoa(" end=")" contains=ALL
syn region sqliteFunction         start="instr(" end=")" contains=ALL
syn region sqliteFunction         start="lcase(" end=")" contains=ALL
syn region sqliteFunction         start="least(" end=")" contains=ALL
syn region sqliteFunction         start="length(" end=")" contains=ALL
syn region sqliteFunction         start="load_file(" end=")" contains=ALL
syn region sqliteFunction         start="locate(" end=")" contains=ALL
syn region sqliteFunction         start="log(" end=")" contains=ALL
syn region sqliteFunction         start="log10(" end=")" contains=ALL
syn region sqliteFunction         start="lower(" end=")" contains=ALL
syn region sqliteFunction         start="lpad(" end=")" contains=ALL
syn region sqliteFunction         start="ltrim(" end=")" contains=ALL
syn region sqliteFunction         start="make_set(" end=")" contains=ALL
syn region sqliteFunction         start="master_pos_wait(" end=")" contains=ALL
syn region sqliteFunction         start="max(" end=")" contains=ALL
syn region sqliteFunction         start="md5(" end=")" contains=ALL
syn region sqliteFunction         start="mid(" end=")" contains=ALL
syn region sqliteFunction         start="min(" end=")" contains=ALL
syn region sqliteFunction         start="mod(" end=")" contains=ALL
syn region sqliteFunction         start="monthname(" end=")" contains=ALL
syn region sqliteFunction         start="now(" end=")" contains=ALL
syn region sqliteFunction         start="oct(" end=")" contains=ALL
syn region sqliteFunction         start="octet_length(" end=")" contains=ALL
syn region sqliteFunction         start="ord(" end=")" contains=ALL
syn region sqliteFunction         start="period_add(" end=")" contains=ALL
syn region sqliteFunction         start="period_diff(" end=")" contains=ALL
syn region sqliteFunction         start="pi(" end=")" contains=ALL
syn region sqliteFunction         start="position(" end=")" contains=ALL
syn region sqliteFunction         start="pow(" end=")" contains=ALL
syn region sqliteFunction         start="power(" end=")" contains=ALL
syn region sqliteFunction         start="quarter(" end=")" contains=ALL
syn region sqliteFunction         start="radians(" end=")" contains=ALL
syn region sqliteFunction         start="rand(" end=")" contains=ALL
syn region sqliteFunction         start="release_lock(" end=")" contains=ALL
syn region sqliteFunction         start="repeat(" end=")" contains=ALL
syn region sqliteFunction         start="reverse(" end=")" contains=ALL
syn region sqliteFunction         start="round(" end=")" contains=ALL
syn region sqliteFunction         start="rpad(" end=")" contains=ALL
syn region sqliteFunction         start="rtrim(" end=")" contains=ALL
syn region sqliteFunction         start="sec_to_time(" end=")" contains=ALL
syn region sqliteFunction         start="session_user(" end=")" contains=ALL
syn region sqliteFunction         start="sign(" end=")" contains=ALL
syn region sqliteFunction         start="sin(" end=")" contains=ALL
syn region sqliteFunction         start="soundex(" end=")" contains=ALL
syn region sqliteFunction         start="space(" end=")" contains=ALL
syn region sqliteFunction         start="sqrt(" end=")" contains=ALL
syn region sqliteFunction         start="std(" end=")" contains=ALL
syn region sqliteFunction         start="stddev(" end=")" contains=ALL
syn region sqliteFunction         start="strcmp(" end=")" contains=ALL
syn region sqliteFunction         start="subdate(" end=")" contains=ALL
syn region sqliteFunction         start="substring(" end=")" contains=ALL
syn region sqliteFunction         start="substring_index(" end=")" contains=ALL
syn region sqliteFunction         start="subtime(" end=")" contains=ALL
syn region sqliteFunction         start="sum(" end=")" contains=ALL
syn region sqliteFunction         start="sysdate(" end=")" contains=ALL
syn region sqliteFunction         start="system_user(" end=")" contains=ALL
syn region sqliteFunction         start="tan(" end=")" contains=ALL
syn region sqliteFunction         start="time_format(" end=")" contains=ALL
syn region sqliteFunction         start="time_to_sec(" end=")" contains=ALL
syn region sqliteFunction         start="to_days(" end=")" contains=ALL
syn region sqliteFunction         start="trim(" end=")" contains=ALL
syn region sqliteFunction         start="ucase(" end=")" contains=ALL
syn region sqliteFunction         start="unique_users(" end=")" contains=ALL
syn region sqliteFunction         start="unix_timestamp(" end=")" contains=ALL
syn region sqliteFunction         start="upper(" end=")" contains=ALL
syn region sqliteFunction         start="user(" end=")" contains=ALL
syn region sqliteFunction         start="version(" end=")" contains=ALL
syn region sqliteFunction         start="week(" end=")" contains=ALL
syn region sqliteFunction         start="weekday(" end=")" contains=ALL
syn region sqliteFunction         start="yearweek(" end=")" contains=ALL

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_sqlite_syn_inits")
  if version < 508
    let did_sqlite_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink sqliteKeyword            Statement
  HiLink sqliteSpecial            Special
  HiLink sqliteString             String
  HiLink sqliteNumber             Number
  HiLink sqliteVariable           Identifier
  HiLink sqliteComment            Comment
  HiLink sqliteType               Type
  HiLink sqliteOperator           Statement
  HiLink sqliteFlow               Statement
  HiLink sqliteFunction           Function
  HiLink sqliteMeta               Special

  delcommand HiLink
endif

let b:current_syntax = "sqlite"

