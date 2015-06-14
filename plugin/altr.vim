" altr - Switch to the missing file without interaction
" Version: 0.2.1
" Copyright (C) 2011-2015 Kana Natsuno <http://whileimautomaton.net/>
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

if exists('g:loaded_altr')
  finish
endif




cnoremap <silent> <Plug>(altr-back)  <C-c>:call altr#back()<Return>
inoremap <silent> <Plug>(altr-back)  <Esc>:call altr#back()<Return>
nnoremap <silent> <Plug>(altr-back)  :<C-u>call altr#back()<Return>
onoremap <silent> <Plug>(altr-back)  <Esc>:call altr#back()<Return>
vnoremap <silent> <Plug>(altr-back)  <Esc>:call altr#back()<Return>

cnoremap <silent> <Plug>(altr-forward)  <C-c>:call altr#forward()<Return>
inoremap <silent> <Plug>(altr-forward)  <Esc>:call altr#forward()<Return>
nnoremap <silent> <Plug>(altr-forward)  :<C-u>call altr#forward()<Return>
onoremap <silent> <Plug>(altr-forward)  <Esc>:call altr#forward()<Return>
vnoremap <silent> <Plug>(altr-forward)  <Esc>:call altr#forward()<Return>




let g:loaded_altr = 1

" __END__
" vim: foldmethod=marker
