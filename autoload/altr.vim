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
  call altr#_switch(bufname('%'), 'back', altr#_rule_table())
endfunction




function! altr#define(...)  "{{{2
  if !(1 <= a:0)
    call s:error('define: 1 or more arguments are required.')
  endif

  " p1       -> p1 p1 p1
  "          b1 |---|
  "          f1    |---|
  " p1 p2    -> p2 p1 p2 p1
  "          b1 |---|
  "          f1    |---|
  "          b2    |---|
  "          f2       |---|
  " p1 p2 p3 -> p3 p1 p2 p3 p1
  "          b1 |---|
  "          f1    |---|
  "          b2    |---|
  "          f2       |---|
  "          b3       |---|
  "          f3          |---|
  let _patterns = a:000
  let first = _patterns[0]
  let last = _patterns[-1]
  let patterns = [last] + _patterns + [first]

  let rule_table = altr#_rule_table()
  for i in range(1, len(_patterns))
    let bp = patterns[i - 1]
    let cp = patterns[i]
    let fp = patterns[i + 1]
    let rule_table[cp] = altr#_make_rule(cp, fp, bp)
  endfor
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
  call altr#_switch(bufname('%'), 'forward', altr#_rule_table())
endfunction




function! altr#remove(...)  "{{{2
  let keys = type(a:1) == type([]) ? a:1 : a:000
  for k in keys
    call remove(altr#_rule_table(), k)
  endfor
endfunction




function! altr#remove_all()  "{{{2
  call altr#remove(keys(altr#_rule_table()))
endfunction




function! altr#reset()  "{{{2
  call altr#remove_all()
  call altr#define_defaults()
endfunction




function! altr#show(current_pattern)  "{{{2
  let v = get(altr#_rule_table(), a:current_pattern, 0)
  if v is 0
    echo printf('No such rule: %s', string(a:current_pattern))
  else
    call v.show()
  endif
endfunction








" Misc.  "{{{1
function! s:error(format, ...)  "{{{2
  throw printf('%s: %s', 'altr', call('printf', a:format, a:000))
endfunction




let s:rule_prototype = {}  "{{{2




function! s:rule_prototype.make(cp, fp, bp)  "{{{2
  let new_self = {
  \   'back_pattern': a:bp,
  \   'current_pattern': a:cp,
  \   'forward_pattern': a:fp,
  \ }
  return extend(new_self, self, 'keep')
endfunction




function! s:rule_prototype.show()  "{{{2
  echo printf('%s -> %s -> %s',
  \           string(self.current_pattern),
  \           string(self.forward_pattern),
  \           string(self.back_pattern))
  \ }
endfunction




function! altr#_regexp_from_pattern(pattern)  "{{{2
  let p = a:pattern
  let p = escape(p, '\\')
  let p = substitute(p, '\V*', '\\.\\*', 'g')
  let p = substitute(p, '\V%', '\\(\\.\\*\\)', '')
  let p = printf('\V\^\.\{-}%s\$', p)
  return p
endfunction




function! altr#_rule_table()  "{{{2
  return s:rule_table
endfunction

let s:rule_table = {}




function! altr#_sort_rules(rule_table)  "{{{2
  " FIXME: Optimize for performance.  Sorted rules are required to infer the
  " missing file, so that this function is called whenever user invoke
  " altr#forward() and altr#back().  Though we have to profile before
  " optimization.
  return reverse(sort(values(a:rule_table), 'altr#_sort_rules_comparer'))
endfunction




function! altr#_sort_rules_comparer(left, right)  "{{{2
  let pd = altr#_priority_from_rule(a:left) - altr#_priority_from_rule(a:right)
  if pd != 0
    return pd
  endif

  if a:left.current_pattern < a:right.current_pattern
    return -1
  elseif a:right.current_pattern < a:left.current_pattern
    return 1
  else
    return 0
  endif
endfunction




function! altr#_switch(basename, direction, rule_table)  "{{{2
  throw 'FIXME: Not implemented yet'
endfunction




" Startup  "{{{2

if !exists('s:loaded')
  call altr#define_defaults()
  let s:loaded = !0
endif








" __END__  "{{{1
" vim: foldmethod=marker
