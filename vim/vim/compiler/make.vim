" Vim compiler file
" Compiler:	Makefile
" Maintainer:   Florian Bruhin <me@the-compiler.org>	
" Last Change:	2012 Sep 07
" Version:      0.1

if exists("current_compiler")
  finish
endif
let current_compiler = "make"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet errorformat=
CompilerSet makeprg=make
