function! P(path)
  return fnamemodify(a:path, ':p')
endfunction




describe 'Switching API'
  before
    tabnew
  end

  after
    tabclose
  end

  it 'uses a full path to guess the next file'
    lcd ./t/vim/autoload

    edit base.vim
    Expect P(bufname('%')) ==# P('../../../t/vim/autoload/base.vim')

    call altr#forward()
    Expect P(bufname('%')) ==# P('../../../t/vim/colors/base.vim')
  end

  it 'uses a full path to guess the previous file'
    lcd ./t/vim/doc

    edit base.txt
    Expect P(bufname('%')) ==# P('../../../t/vim/doc/base.txt')

    call altr#back()
    Expect P(bufname('%')) ==# P('../../../t/vim/compiler/base.vim')
  end
end
