runtime! plugin/altr.vim

let s:to_be_error_info = {}
function! s:to_be_error_info.match(actual)
  return type(a:actual) == type({}) && has_key(a:actual, 'message')
endfunction
call vspec#customize_matcher('to_be_error_info', s:to_be_error_info)




describe 'altr#_escape_replacement'
  it 'should escape special characters for replacement string for substitute()'
    let S = function('substitute')
    let E = function('altr#_escape_replacement')

    Expect E('A-Z a-z 0-9 ...') ==# 'A-Z a-z 0-9 ...'
    Expect E('A-Z&a-z\0-9 ...') ==# 'A-Z\&a-z\\0-9 ...'
    Expect S('foobar', 'oo..', '<&>', '') ==# 'f<ooba>r'
    Expect S('foobar', 'oo..', E('<&>'), '') ==# 'f<&>r'
    Expect S('foobar', 'oo..', '<\0>', '') ==# 'f<ooba>r'
    Expect S('foobar', 'oo..', E('<\0>'), '') ==# 'f<\0>r'
    Expect S('foobar', 'oo..', '<~>', '') ==# 'f<~>r'
    Expect S('foobar', 'oo..', '<\~>', '') ==# 'f<~>r'
  end
end




describe 'altr#_format_rule'
  it 'should show a given rule well'
    Expect altr#_format_rule(altr#_make_rule('current', 'forward', 'back'))
    \ ==# "'back' <- 'current' -> 'forward'"
  end
end




describe 'altr#_glob_path_from_pattern'
  before
    enew!
    let b:G = function('altr#_glob_path_from_pattern')
    function! b:.m(prefix, basepart)
      return ['*UNUSED*', a:prefix, a:basepart] + repeat(['*UNUSED*'], 7)
    endfunction
  end

  it 'should return proper glob path from given pattern'
    Expect b:G('plugin/%.vim', b:.m('', 'altr')) ==# 'plugin/altr.vim'
    Expect b:G('plugin/%.vim', b:.m('./', 'altr')) ==# './plugin/altr.vim'
    Expect b:G('plugin/%.vim', b:.m('~/.vim/', 'altr')) ==# '~/.vim/plugin/altr.vim'
    Expect b:G('*/%.vim', b:.m('./', 'altr')) ==# './*/altr.vim'
    Expect b:G('Makefile', b:.m('~/.vim/', 'altr')) ==# '~/.vim/Makefile'
  end

  it 'should return proper glob path from pattern with "\"s'
    Expect b:G('plugin\%.vim', b:.m('', 'altr')) ==# 'plugin\altr.vim'
    Expect b:G('plugin\%.vim', b:.m('.\', 'altr')) ==# '.\plugin\altr.vim'
    Expect b:G('plugin\%.vim', b:.m('~\.vim\', 'altr')) ==# '~\.vim\plugin\altr.vim'
    Expect b:G('*\%.vim', b:.m('.\', 'altr')) ==# '.\*\altr.vim'
    Expect b:G('Makefile', b:.m('~\.vim\', 'altr')) ==# '~\.vim\Makefile'
  end
end




describe 'altr#_infer_the_missing_path'
  before
    enew!
    function! b:.NormalizePath(path)
      return fnamemodify(a:path, ':p:.')
    endfunction
    let b:I = function('altr#_infer_the_missing_path')
    let b:T = function('altr#_rule_table')
    call altr#remove_all()
  end

  after
    call altr#reset()
  end

  it 'should return error info if there is no rule matching to basename (1-b)'
    Expect b:I('autoload/altr.vim', 'forward', b:T()) to_be_error_info
  end

  it 'should return a inferred path with "literal" rules (1-a, 2-b)'
    call altr#define('autoload/altr.vim', 'plugin/altr.vim')
    Expect b:I('autoload/altr.vim', 'forward', b:T()) is 'plugin/altr.vim'
  end

  it 'should return a inferred path with "%" rules (1-a, 2-b)'
    call altr#define('autoload/%.vim', 'plugin/%.vim')
    Expect b:I('autoload/altr.vim', 'forward', b:T()) is 'plugin/altr.vim'
  end

  it 'should try the "next" of "next" pattern (1-a, 2-b)'
    call altr#define('autoload/%.vim', 'NO SUCH DIR/%.vim', 'plugin/%.vim')
    Expect b:I('autoload/altr.vim', 'forward', b:T()) is 'plugin/altr.vim'
  end

  it 'should work with an absolute path (1-a, 2-b)'
    cd ./plugin
      call altr#define('autoload/%.vim', 'NO SUCH DIR/%.vim', 'plugin/%.vim')
      let d = b:.NormalizePath(getcwd()) . '../'

      Expect b:.NormalizePath(b:I((d . 'autoload/altr.vim'), 'forward', b:T()))
      \ is b:.NormalizePath(d . 'plugin/altr.vim')
      Expect b:.NormalizePath(b:I((d . 'plugin/altr.vim'), 'forward', b:T()))
      \ is b:.NormalizePath(d . 'autoload/altr.vim')
    cd ..
  end

  it 'should return a inffered path with "*" rules (1-a, 2-a)'
    call altr#define('*/%.vim', 'doc/%.txt')

    Expect b:I('autoload/altr.vim', 'forward', b:T()) is 'plugin/altr.vim'
    Expect b:I('plugin/altr.vim', 'forward', b:T()) is 'doc/altr.txt'
    Expect b:I('doc/altr.txt', 'forward', b:T()) is 'autoload/altr.vim'

    Expect b:I('autoload/altr.vim', 'back', b:T()) is 'doc/altr.txt'
    Expect b:I('plugin/altr.vim', 'back', b:T()) is 'autoload/altr.vim'
    Expect b:I('doc/altr.txt', 'back', b:T()) is 'plugin/altr.vim'
  end
end




describe 'altr#_list_paths'
  before
    enew!
    let b:L = function('altr#_list_paths')
    function! b:.m(prefix, basepart)
      return ['*UNUSED*', a:prefix, a:basepart] + repeat(['*UNUSED*'], 7)
    endfunction
  end

  it 'should list an empty list if there is no maching paths'
    Expect b:L('autoload/arpeggio.vim', b:.m('./', 'altr')) ==# []
  end

  it 'should list a path with "literal" pattern'
    Expect b:L('autoload/altr.vim', b:.m('./', 'altr'))
    \      ==# ['./autoload/altr.vim']
  end

  it 'should list a path with "%" pattern'
    Expect b:L('autoload/%.vim', b:.m('./', 'altr'))
    \      ==# ['./autoload/altr.vim']
  end

  it 'should list paths wiwth "*" pattern'
    Expect b:L('*/%.vim', b:.m('./', 'altr'))
    \ ==# ['./autoload/altr.vim', './plugin/altr.vim']
  end
end




describe 'altr#_make_rule'
  it 'should make a rule properly'
    let r = altr#_make_rule('current', 'forward', 'back')
    Expect r.current_pattern ==# 'current'
    Expect r.forward_pattern ==# 'forward'
    Expect r.back_pattern ==# 'back'
  end
end




describe 'altr#_match_with_buffer_name'
  before
    enew!
    let b:R = function('altr#_make_rule')
    let b:M = function('altr#_match_with_buffer_name')
    function! b:.m(whole, prefix, basepart)
      return [a:whole, a:prefix, a:basepart] + repeat([''], 7)
    endfunction
  end

  it 'should perform matching properly'
    Expect b:M(b:R('%.vim', '', ''), 'altr.vim')
    \      ==# [!0, b:.m('altr.vim', '', 'altr')]
    Expect b:M(b:R('%.vim', '', ''), 'plugin/altr.vim')
    \      ==# [!0, b:.m('plugin/altr.vim', '', 'plugin/altr')]
    Expect b:M(b:R('%.vim', '', ''), 'doc/altr.txt')
    \      ==# [!!0, []]
    Expect b:M(b:R('*.vim', '', ''), 'altr.vim')
    \      ==# [!0, b:.m('altr.vim', '', '')]
    Expect b:M(b:R('Makefile', '', ''), 'Makefile')
    \      ==# [!0, b:.m('Makefile', '', '')]

    Expect b:M(b:R('plugin/%.vim', '', ''), 'plugin/altr.vim')
    \      ==# [!0, b:.m('plugin/altr.vim', '', 'altr')]
    Expect b:M(b:R('plugin/%.vim', '', ''), '~/.vim/plugin/altr.vim')
    \      ==# [!0, b:.m('~/.vim/plugin/altr.vim', '~/.vim/', 'altr')]
  end

  it 'should perform matching properly even if path separator is "\"'
    Expect b:M(b:R('plugin/%.vim', '', ''), 'plugin\altr.vim')
    \      ==# [!0, b:.m('plugin/altr.vim', '', 'altr')]
    Expect b:M(b:R('plugin/%.vim', '', ''), '~\.vim\plugin\altr.vim')
    \      ==# [!0, b:.m('~/.vim/plugin/altr.vim', '~/.vim/', 'altr')]
  end
end




describe 'altr#_normalize_buffer_name'
  it 'should normalize given buffer name properly'
    Expect altr#_normalize_buffer_name('foobar') ==# 'foobar'
    Expect altr#_normalize_buffer_name('foo/bar') ==# 'foo/bar'
    Expect altr#_normalize_buffer_name('foo\bar') ==# 'foo/bar'
  end
end




describe 'altr#_priority_from_rule'
  it 'should calculate priority of a given rule properly'
    Expect altr#_priority_from_rule(altr#_make_rule('foo', '', '')) ==# 30
    Expect altr#_priority_from_rule(altr#_make_rule('%.vim', '', '')) ==# 45
    Expect altr#_priority_from_rule(altr#_make_rule('*.vim', '', '')) ==# 41
    Expect altr#_priority_from_rule(altr#_make_rule('%%.vim', '', '')) ==# 50
    Expect altr#_priority_from_rule(altr#_make_rule('**.vim', '', '')) ==# 42
  end
end




describe 'altr#_regexp_from_pattern'
  it 'should make a regular expression properly'
    Expect altr#_regexp_from_pattern('foo') ==# '\V\^\(\.\{-}\)foo\$'
    Expect altr#_regexp_from_pattern('foo/bar') ==# '\V\^\(\.\{-}\)foo/bar\$'
    Expect altr#_regexp_from_pattern('foo\bar') ==# '\V\^\(\.\{-}\)foo\\bar\$'
    Expect altr#_regexp_from_pattern('%.vim') ==# '\V\^\(\.\{-}\)\(\.\*\).vim\$'
    Expect altr#_regexp_from_pattern('*.vim') ==# '\V\^\(\.\{-}\)\.\*.vim\$'
  end
end




describe 'altr#_rule_table'
  it 'should contains the default rules at first'
    let first = copy(altr#_rule_table())
    call altr#reset()
    let reset = copy(altr#_rule_table())

    Expect first ==# reset
  end
end




describe 'altr#_sort_rules'
  it 'should return well sorted rules'
    let R = function('altr#_make_rule')
    let rs = [
    \   R('autoload/%.vim', '', ''),
    \   R('doc/%.txt', '', ''),
    \   R('plugin/%.vim', '', ''),
    \ ]
    let rt = {
    \   rs[0].current_pattern: rs[0],
    \   rs[1].current_pattern: rs[1],
    \   rs[2].current_pattern: rs[2],
    \ }

    Expect map(altr#_sort_rules(rt), 'v:val.current_pattern')
    \ ==# ['autoload/%.vim', 'plugin/%.vim', 'doc/%.txt']
  end
end




describe 'altr#_sort_rules_comparer'
  before
    enew!
    let b:R = function('altr#_make_rule')
    let b:C = function('altr#_sort_rules_comparer')
  end

  it 'should compare rules by priorities'
    Expect b:C(b:R('foo', '', ''), b:R('foo', '', '')) == 0
    Expect b:C(b:R('fo*', '', ''), b:R('foo', '', '')) < 0
    Expect b:C(b:R('fo*', '', ''), b:R('fo%', '', '')) < 0
    Expect b:C(b:R('fo%', '', ''), b:R('foo', '', '')) < 0
  end

  it 'should compare rules by priorities then by current patterns'
    Expect b:C(b:R('bar', '', ''), b:R('foo', '', '')) < 0
    Expect b:C(b:R('ba%', '', ''), b:R('fo%', '', '')) < 0
    Expect b:C(b:R('X', '', ''), b:R('%%%', '', '')) < 0
  end
end




describe 'altr#_switch'
  before
    call altr#remove_all()
    call altr#define('autoload/%.vim', 'doc/%.txt', 'plugin/%.vim')
  end

  after
    enew!
    call altr#reset()
  end

  it 'should show error message if there is no matching rule'
    redir => m
    silent! call altr#_switch('NO SUCH PATH', 'forward', altr#_rule_table())
    redir END
    Expect m =~# '\V\<altr: No rule is matched to the current buffer name.'
  end

  it 'should switch to the missing path forward'
    enew!
    Expect bufname('%') ==# ''

    silent! call altr#_switch('autoload/altr.vim', 'forward', altr#_rule_table())
    Expect bufname('%') ==# 'doc/altr.txt'

    silent! call altr#_switch('doc/altr.txt', 'forward', altr#_rule_table())
    Expect bufname('%') ==# 'plugin/altr.vim'

    silent! call altr#_switch('plugin/altr.vim', 'forward', altr#_rule_table())
    Expect bufname('%') ==# 'autoload/altr.vim'
  end

  it 'should switch to the missing path back'
    enew!
    Expect bufname('%') ==# ''

    silent! call altr#_switch('autoload/altr.vim', 'back', altr#_rule_table())
    Expect bufname('%') ==# 'plugin/altr.vim'

    silent! call altr#_switch('plugin/altr.vim', 'back', altr#_rule_table())
    Expect bufname('%') ==# 'doc/altr.txt'

    silent! call altr#_switch('doc/altr.txt', 'back', altr#_rule_table())
    Expect bufname('%') ==# 'autoload/altr.vim'
  end
end




describe 'altr#_switch__similar_paths'
  before
    tabnew
    let t:I = function('altr#_infer_the_missing_path')
    let t:T = function('altr#_rule_table')

    call altr#remove_all()
    call altr#define('autoload/%.vim', 'doc/%.txt', 'plugin/%.vim')
    let pid = getpid()
    let t:tmpdir = printf('tmp/%s', pid)
    call mkdir(printf('%s/doc', t:tmpdir), 'p')
    call writefile([], printf('%s/doc/eval.txt', t:tmpdir))
    silent help eval.txt | close
    cd `=t:tmpdir`
  end

  after
    cd -
    enew!
    silent execute '!' 'rm -r' t:tmpdir
    call altr#reset()
    tabclose
  end

  it 'should distinguish similar paths'
    let bn_help = bufnr(printf('^%s/doc/eval.txt$', $VIMRUNTIME))
    Expect bn_help != -1
    Expect bufnr('doc/eval.txt') == bn_help
    Expect t:I('autoload/eval.vim', 'forward', t:T()) is# 'doc/eval.txt'
    enew!
    Expect bufname('') ==# ''
    silent! call altr#_switch('autoload/eval.vim', 'forward', t:T())
    Expect bufname('') ==# 'doc/eval.txt'
    Expect bufnr('') != bn_help

    let bn_tmp = bufnr(printf('%s/doc/eval.txt', getcwd()), !0)
    Expect bn_tmp != -1
    Expect bn_tmp != bn_help
    Expect bufnr('doc/eval.txt') == bn_tmp
    Expect t:I('autoload/eval.vim', 'forward', t:T()) is# 'doc/eval.txt'
    enew!
    Expect bufname('') ==# ''
    silent! call altr#_switch('autoload/eval.vim', 'forward', t:T())
    Expect bufname('') ==# 'doc/eval.txt'
    Expect bufnr('') == bn_tmp
  end
end
