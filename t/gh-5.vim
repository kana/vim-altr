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
    lcd ./t/fixtures/vim/indent

    edit base.vim
    Expect P(bufname('%')) ==# P('../../../../t/fixtures/vim/indent/base.vim')

    call altr#forward()
    Expect P(bufname('%')) ==# P('../../../../t/fixtures/vim/keymap/base.vim')
  end

  it 'uses a full path to guess the previous file'
    lcd ./t/fixtures/vim/plugin

    edit base.vim
    Expect P(bufname('%')) ==# P('../../../../t/fixtures/vim/plugin/base.vim')

    call altr#back()
    Expect P(bufname('%')) ==# P('../../../../t/fixtures/vim/lang/base.vim')
  end
end
