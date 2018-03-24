runtime! plugin/altr.vim

" NB: vim-vspec runs a test script in Ex mode.  In Ex mode, the cursor
" position is always reset to the last line of a file whenever a file is
" opened, even if the file is already in the buffer list and :buffer is
" used to open the file.  This behavior is different from the one in
" interactive use.  So this test script is forced to run in interactive mode.
"
" Note that it is not possible to go back to Ex mode via Vim script.
visual

describe 'altr'
  before
    %bdelete
  end

  it 'uses :buffer to keep the cursor line for a file opened before'
    silent! edit autoload/altr.vim
    normal! 50G
    let last_curcor_line = line('.')
    Expect bufname('%') ==# 'autoload/altr.vim'
    Expect last_curcor_line > 1
    Expect &l:buflisted to_be_true

    silent! call altr#forward()
    Expect bufname('%') ==# 'doc/altr.txt'

    silent! call altr#back()
    Expect bufname('%') ==# 'autoload/altr.vim'
    Expect line('.') == last_curcor_line
    Expect &l:buflisted to_be_true
  end
end
