let s:to_echo = {}
function! s:to_echo.match(command, partial_message)
  redir => self.actual_message
  execute a:command
  redir END
  return stridx(self.actual_message, a:partial_message) != -1
endfunction
function! s:to_echo.failure_message_for_should(command, partial_message)
  return [
  \   '    Actual message: ' . string(strtrans(self.actual_message)),
  \   'Expected substring: ' . string(strtrans(a:partial_message)),
  \ ]
endfunction
call vspec#customize_matcher('to_echo', s:to_echo)


describe 'altr#forward / altr#back'
  it 'shows a message if there is no rule for the current buffer'
    let unknown_path = 't/fixtures/no-such-file.txt'
    edit `=unknown_path`

    Expect 'call altr#forward()' to_echo 'No rule is matched'
    Expect bufname('%') ==# unknown_path

    Expect 'call altr#back()' to_echo 'No rule is matched'
    Expect bufname('%') ==# unknown_path
  end

  it 'shows a message if there is no next/previous file'
    let path = 't/fixtures/vim/autoload/only.vim'
    edit `=path`

    Expect 'call altr#forward()' to_echo 'The next file is not found'
    Expect bufname('%') ==# path

    Expect 'call altr#back()' to_echo 'The previous file is not found'
    Expect bufname('%') ==# path
  end
end
