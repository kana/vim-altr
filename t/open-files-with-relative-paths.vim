describe 'altr#forward and altr#back'
  before
    new
  end

  after
    close!
  end

  it 'open a file with a relative path'
    edit t/fixtures/vim/doc/base.txt
    Expect bufname('%') ==# 't/fixtures/vim/doc/base.txt'

    call altr#forward()
    Expect bufname('%') ==# 't/fixtures/vim/ftdetect/base.vim'

    call altr#back()
    call altr#back()
    Expect bufname('%') ==# 't/fixtures/vim/compiler/base.vim'
  end
end
