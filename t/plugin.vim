runtime! plugin/altr.vim

describe 'plugin/altr.vim'
  it 'should be loaded'
    Expect exists('g:loaded_altr') toBeTrue
  end

  it 'should provide <Plug>(atlr-back)'
    Expect maparg('<Plug>(altr-back)', 'n') =~# '\Valtr#back()'
    Expect maparg('<Plug>(altr-back)', 'x') =~# '\Valtr#back()'
    Expect maparg('<Plug>(altr-back)', 's') =~# '\Valtr#back()'
    Expect maparg('<Plug>(altr-back)', 'o') =~# '\Valtr#back()'
    Expect maparg('<Plug>(altr-back)', 'i') =~# '\Valtr#back()'
    Expect maparg('<Plug>(altr-back)', 'c') =~# '\Valtr#back()'
    Expect maparg('<Plug>(altr-back)', 'l') ==# ''
  end

  it 'should provide <Plug>(atlr-forward)'
    Expect maparg('<Plug>(altr-forward)', 'n') =~# '\Valtr#forward()'
    Expect maparg('<Plug>(altr-forward)', 'x') =~# '\Valtr#forward()'
    Expect maparg('<Plug>(altr-forward)', 's') =~# '\Valtr#forward()'
    Expect maparg('<Plug>(altr-forward)', 'o') =~# '\Valtr#forward()'
    Expect maparg('<Plug>(altr-forward)', 'i') =~# '\Valtr#forward()'
    Expect maparg('<Plug>(altr-forward)', 'c') =~# '\Valtr#forward()'
    Expect maparg('<Plug>(altr-forward)', 'l') ==# ''
  end
end
