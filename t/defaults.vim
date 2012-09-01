runtime! plugin/altr.vim

describe 'Default rules'
  before
    tabnew

    function! t:.test(files)
      for i in range(len(a:files))
        if i == 0
          silent edit `=a:files[i]`
        else
          silent call altr#forward()
        endif
        Expect [i, bufname('%')] ==# [i, a:files[i]]
      endfor
    endfunction
  end

  after
    tabclose!
  end

  it 'has rules for Vim script'
    call t:.test([
    \   't/vim/autoload/base.vim',
    \   't/vim/colors/base.vim',
    \   't/vim/compiler/base.vim',
    \   't/vim/doc/base.txt',
    \   't/vim/ftdetect/base.vim',
    \   't/vim/ftplugin/base.vim',
    \   't/vim/ftplugin/base_any1.vim',
    \   't/vim/ftplugin/base_any2.vim',
    \   't/vim/ftplugin/base/any1.vim',
    \   't/vim/ftplugin/base/any2.vim',
    \   't/vim/indent/base.vim',
    \   't/vim/keymap/base.vim',
    \   't/vim/lang/base.vim',
    \   't/vim/plugin/base.vim',
    \   't/vim/syntax/base.vim',
    \   't/vim/syntax/any1/base.vim',
    \   't/vim/syntax/any2/base.vim',
    \   't/vim/after/autoload/base.vim',
    \   't/vim/after/colors/base.vim',
    \   't/vim/after/compiler/base.vim',
    \   't/vim/after/doc/base.txt',
    \   't/vim/after/ftdetect/base.vim',
    \   't/vim/after/ftplugin/base.vim',
    \   't/vim/after/ftplugin/base_any1.vim',
    \   't/vim/after/ftplugin/base_any2.vim',
    \   't/vim/after/ftplugin/base/any1.vim',
    \   't/vim/after/ftplugin/base/any2.vim',
    \   't/vim/after/indent/base.vim',
    \   't/vim/after/keymap/base.vim',
    \   't/vim/after/lang/base.vim',
    \   't/vim/after/plugin/base.vim',
    \   't/vim/after/syntax/base.vim',
    \   't/vim/after/syntax/any1/base.vim',
    \   't/vim/after/syntax/any2/base.vim',
    \ ])
  end

  it 'has rules for C family'
    call t:.test([
    \   't/c-family/base.c',
    \   't/c-family/base.h',
    \ ])
  end

  it 'has rules for ASP.NET'
    call t:.test([
    \   't/asp.net/base.asax',
    \   't/asp.net/base.asax.cs',
    \ ])
    call t:.test([
    \   't/asp.net/base.ascx',
    \   't/asp.net/base.ascx.cs',
    \   't/asp.net/base.ascx.designer.cs',
    \   't/asp.net/base.ascx.resx',
    \ ])
    call t:.test([
    \   't/asp.net/base.aspx',
    \   't/asp.net/base.aspx.cs',
    \   't/asp.net/base.aspx.designer.cs',
    \   't/asp.net/base.aspx.resx',
    \ ])
  end
end
