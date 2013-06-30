runtime! plugin/altr.vim

function! P(path)
  return fnamemodify(a:path, ':p')
endfunction




describe 'altr#back'
  before
    call altr#remove_all()
    call altr#define('autoload/%.vim', 'NONE/%.vim', 'doc/%.txt', 'plugin/%.vim')
  end

  it 'should switch to the missing path forward'
    silent view autoload/altr.vim
    Expect P(bufname('%')) ==# P('autoload/altr.vim')

    silent! call altr#back()
    Expect P(bufname('%')) ==# P('plugin/altr.vim')

    silent! call altr#back()
    Expect P(bufname('%')) ==# P('doc/altr.txt')

    silent! call altr#back()
    Expect P(bufname('%')) ==# P('autoload/altr.vim')
  end

  after
    enew!
    call altr#reset()
  end
end




describe 'altr#define'
  before
    enew!
    let b:R = function('altr#_make_rule')
  end

  after
    call altr#reset()
  end

  it 'should define a given rule'
    let first = copy(altr#_rule_table())
    Expect has_key(first, 'foo') toBeFalse
    Expect has_key(first, 'bar') toBeFalse
    Expect has_key(first, 'baz') toBeFalse
    Expect has_key(first, 'qux') toBeFalse

    call altr#define('foo')
    let defined1 = copy(altr#_rule_table())
    Expect defined1['foo'] ==# b:R('foo', 'foo', 'foo')

    call altr#define('foo', 'bar')
    let defined2 = copy(altr#_rule_table())
    Expect defined2['foo'] ==# b:R('foo', 'bar', 'bar')
    Expect defined2['bar'] ==# b:R('bar', 'foo', 'foo')

    call altr#define('foo', 'bar', 'baz')
    let defined3 = copy(altr#_rule_table())
    Expect defined3['foo'] ==# b:R('foo', 'bar', 'baz')
    Expect defined3['bar'] ==# b:R('bar', 'baz', 'foo')
    Expect defined3['baz'] ==# b:R('baz', 'foo', 'bar')

    call altr#define('foo', 'bar', 'baz', 'qux')
    let defined4 = copy(altr#_rule_table())
    Expect defined4['foo'] ==# b:R('foo', 'bar', 'qux')
    Expect defined4['bar'] ==# b:R('bar', 'baz', 'foo')
    Expect defined4['baz'] ==# b:R('baz', 'qux', 'bar')
    Expect defined4['qux'] ==# b:R('qux', 'foo', 'baz')
  end

  it 'should define a given rule which is passed as a list of patterns'
    call altr#define(['mon', 'tue', 'wed'])
    let defined5 = copy(altr#_rule_table())
    Expect defined5['mon'] ==# b:R('mon', 'tue', 'wed')
    Expect defined5['tue'] ==# b:R('tue', 'wed', 'mon')
    Expect defined5['wed'] ==# b:R('wed', 'mon', 'tue')
  end
end




describe 'altr#define_defaults'
  " FIXME: How should it be tested?
end




describe 'altr#forward'
  before
    call altr#remove_all()
    call altr#define('autoload/%.vim', 'NONE/%.vim', 'doc/%.txt', 'plugin/%.vim')
  end

  after
    enew!
    call altr#reset()
  end

  it 'should switch to the missing path forward'
    silent view autoload/altr.vim
    Expect P(bufname('%')) ==# P('autoload/altr.vim')

    silent! call altr#forward()
    Expect P(bufname('%')) ==# P('doc/altr.txt')

    silent! call altr#forward()
    Expect P(bufname('%')) ==# P('plugin/altr.vim')

    silent! call altr#forward()
    Expect P(bufname('%')) ==# P('autoload/altr.vim')
  end
end




describe 'altr#remove'
  it 'should remove a given rule'
    let first = copy(altr#_rule_table())

    Expect has_key(first, 'plugin/%.vim') toBeTrue

    call altr#remove('plugin/%.vim')
    let removed = copy(altr#_rule_table())

    Expect has_key(removed, 'plugin/%.vim') toBeFalse

    call altr#reset()
  end
end




describe 'altr#remove_all'
  it 'should remove all rules'
    let first = copy(altr#_rule_table())

    Expect empty(first) toBeFalse

    call altr#remove_all()
    let removed = copy(altr#_rule_table())

    Expect empty(removed) toBeTrue

    call altr#reset()
  end
end




describe 'altr#reset'
  it 'should reset to the default state'
    call altr#remove_all()
    call altr#define_defaults()
    let clear_then_define = copy(altr#_rule_table())

    call altr#reset()
    let reset = copy(altr#_rule_table())

    Expect reset ==# clear_then_define
  end
end




describe 'altr#show'
  it 'should show a defined rule well'
    redir => output
    silent call altr#show('plugin/%.vim')
    redir END
    Expect output ==# "\n'lang/%.vim' <- 'plugin/%.vim' -> 'syntax/%.vim'"
  end

  it 'should show an undefined rule well'
    redir => output
    silent call altr#show('&$!*()&$!')
    redir END
    Expect output ==# "\naltr: No such rule: '&$!*()&$!'"
  end
end




