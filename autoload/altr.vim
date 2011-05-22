" altr - Switch to the missing file without interaction
" Version: 0.0.0
" Copyright (C) 2011 Kana Natsuno <http://whileimautomaton.net/>
" License: So-called MIT/X license  {{{
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
" Interface  "{{{1
function! altr#back()  "{{{2
  call altr#_switch(bufname('%'), 'back', altr#_rules())
endfunction




function! altr#define(...)  "{{{2
  throw 'FIXME: Not implemented yet'
endfunction




function! altr#define_defaults()  "{{{2
  call altr#define('autoload/%.vim',
  \                'colors/%.vim',
  \                'compiler/%.vim',
  \                'doc/%.txt',
  \                'ftdetect/%.vim',
  \                'ftplugin/%.vim',
  \                'ftplugin/%_*.vim',
  \                'ftplugin/%/*.vim',
  \                'indent/%.vim',
  \                'keymap/%.vim',
  \                'lang/%.vim',
  \                'plugin/%.vim',
  \                'syntax/%.vim')
  call altr#define('%.c', '%.h')  " FIXME: Refine.
  call altr#define('%.aspx', '%.aspx.cs')  " FIXME: Refine.
  call altr#define('%.ascx', '%.ascx.cs')  " FIXME: Refine.
  " FIXME: Add more useful defaults.
endfunction




function! altr#forward()  "{{{2
  call altr#_switch(bufname('%'), 'forward', altr#_rules())
endfunction




function! altr#remove(...)  "{{{2
  throw 'FIXME: Not implemented yet'
endfunction




function! altr#remove_all()  "{{{2
  call altr#remove(keys(altr#_rules()))
endfunction




function! altr#reset()  "{{{2
  call altr#remove_all()
  call altr#define_defaults()
endfunction




function! altr#show(pattern)  "{{{2
  throw 'FIXME: Not implemented yet'
endfunction








" Misc.  "{{{1
function! altr#_rules()  "{{{2
  return s:rules
endfunction

let s:rules = {}




function! altr#_switch(basename, direction, rules)  "{{{2
  throw 'FIXME: Not implemented yet'
endfunction




" Startup  "{{{2

if !exists('s:loaded')
  call altr#define_defaults()
  let s:loaded = !0
endif








" __END__  "{{{1
" vim: foldmethod=marker
