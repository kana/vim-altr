" altr - Switch to the missing file without interaction
" Version: 0.0.3
" Copyright (C) 2011-2013 Kana Natsuno <http://whileimautomaton.net/>
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
" Interface  "{{{1
function! altr#back()  "{{{2
  call altr#_switch(expand('%:p'), 'back', altr#_rule_table())
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
  let _patterns = type(a:1) == type([]) ? a:1 : a:000
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
  let vim_runtime_files = [
  \   'autoload/%.vim',
  \   'colors/%.vim',
  \   'compiler/%.vim',
  \   'doc/%.txt',
  \   'ftdetect/%.vim',
  \   'ftplugin/%.vim',
  \   'ftplugin/%_*.vim',
  \   'ftplugin/%/*.vim',
  \   'indent/%.vim',
  \   'keymap/%.vim',
  \   'lang/%.vim',
  \   'plugin/%.vim',
  \   'syntax/%.vim',
  \   'syntax/*/%.vim',
  \ ]
  let vim_after_runtime_files = map(copy(vim_runtime_files), '"after/".v:val')
  call altr#define(vim_after_runtime_files + vim_runtime_files)

  call altr#define('%.c', '%.cpp', '%.m', '%.h', '%.hpp')

  call altr#define('%.asax', '%.asax.cs')
  call altr#define('%.ascx', '%.ascx.cs', '%.ascx.designer.cs', '%.ascx.resx') 
  call altr#define('%.aspx', '%.aspx.cs', '%.aspx.designer.cs', '%.aspx.resx') 

  " FIXME: Add more useful defaults.
endfunction




function! altr#forward()  "{{{2
  call altr#_switch(expand('%:p'), 'forward', altr#_rule_table())
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
    call s:notice('No such rule: %s', string(a:current_pattern))
  else
    echo altr#_format_rule(v)
  endif
endfunction








" Misc.  "{{{1
" Constants  "{{{2

let s:E_NO_RULE = {'message': 'No rule is matched to the current buffer name.'}




function! s:error(format, ...)  "{{{2
  throw call('s:format', a:000)
endfunction




function! s:format(format, ...)  "{{{2
  return call('printf', ['%s: ' . a:format, 'altr'] + a:000)
endfunction




function! s:notice(...)  "{{{2
  echo call('s:format', a:000)
endfunction




function! s:warn(...)  "{{{2
  echomsg call('s:format', a:000)
endfunction




function! altr#_escape_replacement(s)  "{{{2
  " Escape special characters for replacement string for substitute().
  " According to :help substitute() and :help sub-replace-special,
  " only \ and & must be escaped.
  return escape(a:s, '\&')
endfunction




function! altr#_format_rule(rule)  "{{{2
  return printf('%s <- %s -> %s',
  \             string(a:rule.back_pattern),
  \             string(a:rule.current_pattern),
  \             string(a:rule.forward_pattern))
endfunction




function! altr#_glob_path_from_pattern(pattern, matched_parts)  "{{{2
  let prefix = a:matched_parts[1]
  let basepart = altr#_escape_replacement(a:matched_parts[2])
  return prefix . substitute(a:pattern, '%', basepart, 'g')
endfunction




function! altr#_infer_the_missing_path(bufname, direction, rule_table)  "{{{2
  let rules = altr#_sort_rules(a:rule_table)
  for r in rules
    let [matchedp, match] = altr#_match_with_buffer_name(r, a:bufname)
    if matchedp
      let step = (r.current_pattern =~# '\V*'
      \           ? 's:infer_step_2_a'
      \           : 's:infer_step_2_b')
      let path = call(step, [a:bufname, a:direction, a:rule_table, r, match])
      if path isnot 0
        return path
      endif
    endif
  endfor

  return s:E_NO_RULE
endfunction

function! s:infer_step_2_a(bufname, direction, rule_table, rule, match)
  let paths = altr#_list_paths(a:rule.current_pattern, a:match)
  let i = index(paths, a:bufname)
  if i == -1
    call s:warn('Something wrong - %s not found in %s',
    \           string(a:bufname),
    \           string(a:rule.current_pattern))
    return 0
  endif

  if a:direction ==# 'forward' && i + 1 < len(paths)
    return paths[i + 1]
  elseif a:direction ==# 'back' && 0 <= i - 1
    return paths[i - 1]
  else
    return s:infer_step_2_b(a:bufname,
    \                       a:direction,
    \                       a:rule_table,
    \                       a:rule,
    \                       a:match)
  endif
endfunction

function! s:infer_step_2_b(bufname, direction, rule_table, rule, match)
  let forward_p = a:direction ==# 'forward'
  let cr = a:rule

  while !0
    let pattern = cr[forward_p ? 'forward_pattern' : 'back_pattern']
    if pattern ==# a:rule.current_pattern
      break
    endif

    let paths = altr#_list_paths(pattern, a:match)
    if !empty(paths)
      return paths[forward_p ? 0 : -1]
    endif

    unlet cr
    let cr = get(a:rule_table, pattern, 0)
    if cr is 0
      call s:error('Rule for %s is not defined.  Something is wrong.',
      \            string(pattern))
    endif
  endwhile

  return 0
endfunction




function! altr#_list_paths(pattern, matched_parts)  "{{{2
  " NB: On Windows environments, the proper path separator is '\', but '/' may
  " be used to list paths.  So that '/'s in a:pattern are left as is.
  "
  " Souce: http://msdn.microsoft.com/en-us/library/aa365247(v=vs.85).aspx
  " > File I/O functions in the Windows API convert "/" to "\" as part of
  " > converting the name to an NT-style name, except when using the "\\?\"
  " > prefix as detailed in the following sections.

  return split(
  \   glob(altr#_glob_path_from_pattern(a:pattern, a:matched_parts)),
  \   "\n"
  \ )
endfunction




function! altr#_make_rule(cp, fp, bp)  "{{{2
  return {
  \   'back_pattern': a:bp,
  \   'current_pattern': a:cp,
  \   'forward_pattern': a:fp,
  \ }
endfunction




function! altr#_match_with_buffer_name(rule, buffer_name)  "{{{2
  " NB: On Windows environments, '\' and '/' can be used interchangably to
  " glob paths.  Windows API takes care of this path separator convention.
  " But buffer name matching is performed in the Vim world, not in Windows
  " API.  So that a:buffer_name should be normalized to use the same rule
  " definitions for both Windows environments and non-Windows environments.
  "
  " Souce: http://msdn.microsoft.com/en-us/library/aa365247(v=vs.85).aspx

  let xs = matchlist(altr#_normalize_buffer_name(a:buffer_name),
  \                  altr#_regexp_from_pattern(a:rule.current_pattern))
  return [!empty(xs), xs]
endfunction




function! altr#_normalize_buffer_name(buffer_name)  "{{{2
  return substitute(a:buffer_name, '\\', '/', 'g')
endfunction




function! altr#_priority_from_rule(rule)  "{{{2
  let p = len(substitute(a:rule.current_pattern, '[^%]', '', 'g'))
  let s = len(substitute(a:rule.current_pattern, '[^*]', '', 'g'))
  let c = len(a:rule.current_pattern) - p - s
  return 10 * c + 5 * p + 1 * s
endfunction




function! altr#_regexp_from_pattern(pattern)  "{{{2
  let p = a:pattern
  let p = escape(p, '\\')
  let p = substitute(p, '\V*', '\\.\\*', 'g')
  let p = substitute(p, '\V%', '\\(\\.\\*\\)', '')
  let p = printf('\V\^\(\.\{-}\)%s\$', p)
  return p
endfunction




function! altr#_rule_table()  "{{{2
  return s:rule_table
endfunction




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




function! altr#_switch(...)  "{{{2
  let path = call('altr#_infer_the_missing_path', a:000)
  if path is s:E_NO_RULE
    call s:notice(path.message)
  else
    " NB: bufnr() doesn't use a given {expr} literally.  According to :help
    " bufname() --
    "
    " > A full match is preferred, otherwise a match at the start, end or
    " > middle of the buffer name is accepted.
    "
    " Suppose that there are two buffers of which paths are "./doc/eval.txt"
    " and "$VIMRUNTIME/doc/eval.txt".  The above sentence means that
    " bufnr('doc/eval.txt') may return the buffer number for
    " "$VIMRUNTIME/doc/eval.txt" rather than the one for "./doc/eval.txt".
    "
    " This behavior causes unexpected results.  {expr} for bufnr() should be
    " escaped properly.  According to :help bufname() --
    "
    " > If you only want a full match then put "^" at the start and "$" at the
    " > end of the pattern.
    let n = bufnr(printf('^%s$', path))
    if n == -1
      " The default 'statusline' uses %f to show a file path.  According to
      " :help, %f shows a path "as typed or relative to current directory".
      " Therefore, if a file is opened by ":edit ../../foo/bar/baz", %f always
      " shows a file path as "../../foo/bar/baz" rather than "bar/baz", even
      " if the current directory is "foo".  To simplify paths in status lines,
      " here we have to use relative paths to open unvisited files.
      edit `=fnamemodify(path, ':.')`
    else
      " NB: Unlike <C-^>, :[N]buffer doesn't restore the last cursor position
      " of a buffer perfectly.  Only the cursor line is restored.  The cursor
      " column is always moved to the first column (in a sense of 0).
      execute n 'buffer'
    endif
  endif
endfunction




" Startup  "{{{2

if !exists('s:loaded')
  let s:rule_table = {}

  call altr#define_defaults()

  let s:loaded = !0
endif








" __END__  "{{{1
" vim: foldmethod=marker
