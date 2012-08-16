runtime! plugin/altr.vim

describe 'autoload/altr.vim'
  after
    call altr#reset()
  end

  it 'should keep the rule table before and after reloading autoload script'
    call altr#reset()
    call altr#define('%.vim', '%.txt')
    let old_rule_table = copy(altr#_rule_table())

    runtime! autoload/altr.vim

    let new_rule_table = copy(altr#_rule_table())
    Expect new_rule_table ==# old_rule_table
  end
end
