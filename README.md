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
    \ 'allowlist': ['*'],
    \ 'blocklist': ['go'],
    \ 'completor': function('asyncomplete#sources#buffer#completor'),
    \ 'config': {
    \    'max_buffer_size': 5000000,
    \  },
    \ }))
```
Note: config is optional. `max_buffer_size` defaults to 5000000 (5mb). If the buffer size exceeds `max_buffer_size` it is ignored. Set `max_buffer_size` to -1 for unlimited buffer size.

### Options

Clear buffer word cache on events (default: `1`)
```vim
let g:asyncomplete_buffer_clear_cache = 1
```

### Credits
All the credit goes to the following projects
* [https://github.com/roxma/nvim-complete-manager](https://github.com/roxma/nvim-complete-manager)
