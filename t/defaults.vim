runtime! plugin/altr.vim

function! P(path)
  return fnamemodify(a:path, ':p')
endfunction

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
        Expect [i, P(bufname('%'))] ==# [i, P(a:files[i])]
      endfor
    endfunction
  end

  after
    tabclose!
  end

  it 'has rules for Vim script'
    call t:.test([
    \   't/fixtures/vim/autoload/base.vim',
    \   't/fixtures/vim/colors/base.vim',
    \   't/fixtures/vim/compiler/base.vim',
    \   't/fixtures/vim/doc/base.txt',
    \   't/fixtures/vim/ftdetect/base.vim',
    \   't/fixtures/vim/ftplugin/base.vim',
    \   't/fixtures/vim/ftplugin/base_any1.vim',
    \   't/fixtures/vim/ftplugin/base_any2.vim',
    \   't/fixtures/vim/ftplugin/base/any1.vim',
    \   't/fixtures/vim/ftplugin/base/any2.vim',
    \   't/fixtures/vim/indent/base.vim',
    \   't/fixtures/vim/keymap/base.vim',
    \   't/fixtures/vim/lang/base.vim',
    \   't/fixtures/vim/plugin/base.vim',
    \   't/fixtures/vim/syntax/base.vim',
    \   't/fixtures/vim/syntax/base/any1.vim',
    \   't/fixtures/vim/syntax/base/any2.vim',
    \   't/fixtures/vim/after/autoload/base.vim',
    \   't/fixtures/vim/after/colors/base.vim',
    \   't/fixtures/vim/after/compiler/base.vim',
    \   't/fixtures/vim/after/doc/base.txt',
    \   't/fixtures/vim/after/ftdetect/base.vim',
    \   't/fixtures/vim/after/ftplugin/base.vim',
    \   't/fixtures/vim/after/ftplugin/base_any1.vim',
    \   't/fixtures/vim/after/ftplugin/base_any2.vim',
    \   't/fixtures/vim/after/ftplugin/base/any1.vim',
    \   't/fixtures/vim/after/ftplugin/base/any2.vim',
    \   't/fixtures/vim/after/indent/base.vim',
    \   't/fixtures/vim/after/keymap/base.vim',
    \   't/fixtures/vim/after/lang/base.vim',
    \   't/fixtures/vim/after/plugin/base.vim',
    \   't/fixtures/vim/after/syntax/base.vim',
    \   't/fixtures/vim/after/syntax/base/any1.vim',
    \   't/fixtures/vim/after/syntax/base/any2.vim',
    \ ])
  end

  it 'has rules for operator-user based Vim plugins'
    call t:.test([
    \   't/fixtures/vim/autoload/operator/foo.vim',
    \   't/fixtures/vim/doc/operator-foo.txt',
    \   't/fixtures/vim/plugin/operator/foo.vim',
    \ ])
  end

  it 'has rules for textobj-user based Vim plugins'
    call t:.test([
    \   't/fixtures/vim/autoload/textobj/foo.vim',
    \   't/fixtures/vim/doc/textobj-foo.txt',
    \   't/fixtures/vim/plugin/textobj/foo.vim',
    \ ])
  end

  it 'has rules for C family'
    call t:.test([
    \   't/fixtures/c-family/base.c',
    \   't/fixtures/c-family/base.cpp',
    \   't/fixtures/c-family/base.cc',
    \   't/fixtures/c-family/base.m',
    \   't/fixtures/c-family/base.mm',
    \   't/fixtures/c-family/base.h',
    \   't/fixtures/c-family/base.hpp',
    \ ])
  end

  it 'has rules for C#'
    call t:.test([
    \   't/fixtures/cs/base.cs',
    \   't/fixtures/cs/base.designer.cs',
    \ ])
  end

  it 'has rules for ASP.NET'
    call t:.test([
    \   't/fixtures/asp.net/base.asax',
    \   't/fixtures/asp.net/base.asax.cs',
    \ ])
    call t:.test([
    \   't/fixtures/asp.net/base.ascx',
    \   't/fixtures/asp.net/base.ascx.cs',
    \   't/fixtures/asp.net/base.ascx.designer.cs',
    \   't/fixtures/asp.net/base.ascx.resx',
    \ ])
    call t:.test([
    \   't/fixtures/asp.net/base.aspx',
    \   't/fixtures/asp.net/base.aspx.cs',
    \   't/fixtures/asp.net/base.aspx.designer.cs',
    \   't/fixtures/asp.net/base.aspx.resx',
    \ ])
  end

  it 'has rules for Python'
    call t:.test([
    \   't/fixtures/python/foo.py',
    \   't/fixtures/python/test_foo.py',
    \   't/fixtures/python/tests/test_foo.py',
    \ ])
  end
end
