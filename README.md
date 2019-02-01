Buffer source for asyncomplete.vim
==================================

Provide buffer autocompletion source for [asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim)

### Installing

```vim
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
```

#### Registration

```vim
call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
    \ 'name': 'buffer',
    \ 'whitelist': ['*'],
    \ 'blacklist': ['go'],
    \ 'completor': function('asyncomplete#sources#buffer#completor'),
    \ }))
```

### Options

Clear buffer word cache on events (default: `1`)
```vim
let g:asyncomplete_buffer_clear_cache = 1
```

### Credits
All the credit goes to the following projects
* [https://github.com/roxma/nvim-complete-manager](https://github.com/roxma/nvim-complete-manager)
