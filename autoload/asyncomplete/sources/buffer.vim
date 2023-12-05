let s:words = {}
let s:last_word = ''
let g:asyncomplete_buffer_clear_cache = get(g:, 'asyncomplete_buffer_clear_cache', 1)
let g:asyncomplete_buffer_identify_words_regex = get(g:, 'asyncomplete_buffer_identify_words_regex', '\w\+')

function! asyncomplete#sources#buffer#completor(opt, ctx)
    call asyncomplete#log('asyncomplete#buffer ctx', a:ctx)

    if empty(s:words)
        return
    endif

    let l:matches = []
    let l:col = a:ctx['col']
    let l:typed = a:ctx['typed']

    let l:kw = matchstr(l:typed, g:asyncomplete_buffer_identify_words_regex .'$')
    let l:kwlen = len(l:kw)

    if l:kwlen < 1
        return
    endif

    let l:words = keys(s:words)
    if !empty(s:last_word) && l:kw !=? s:last_word && !has_key(s:words, s:last_word)
        let l:words += [s:last_word]
    endif

    let l:matches = map(l:words,'{"word":v:val,"dup":1,"icase":1,"menu": "[buffer]"}')
    let l:startcol = l:col - l:kwlen

    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
endfunction

function! asyncomplete#sources#buffer#get_source_options(opts)
    return extend({
        \ 'events': ['CursorHold','CursorHoldI','BufWinEnter','BufWritePost','TextChangedI'],
        \ 'on_event': function('s:on_event'),
        \}, a:opts)
endfunction

let s:last_ctx = {}
function! s:on_event(opt, ctx, event) abort
    let l:max_buffer_size = 5000000 " 5mb
    if has_key(a:opt, 'config') && has_key(a:opt['config'], 'max_buffer_size')
        let l:max_buffer_size = a:opt['config']['max_buffer_size']
    endif
    if l:max_buffer_size != -1
        let l:buffer_size = line2byte(line('$') + 1)
        if l:buffer_size > l:max_buffer_size
            call asyncomplete#log('asyncomplete#sources#buffer', 'ignoring buffer autocomplete due to large size', expand('%:p'), l:buffer_size)
            return
        endif
    endif

    if a:event ==# 'TextChangedI'
        call s:refresh_keyword_incr(a:ctx['typed'])
    else
        if s:last_ctx == a:ctx
            return
        endif
        let s:last_ctx = a:ctx
        call s:refresh_keywords()
    endif
endfunction

function! s:refresh_keywords() abort
    if g:asyncomplete_buffer_clear_cache
        let s:words = {}
    endif
    let l:text = join(getline(1, '$'), "\n")
    for l:word in s:split_words(l:text)
        if len(l:word) > 1
            let s:words[l:word] = 1
        endif
    endfor
endfunction

function! s:refresh_keyword_incr(typed) abort
    let l:words = s:split_words(a:typed)
    if len(l:words) > 1
        for l:word in l:words[:len(l:words)-2]
                let s:words[l:word] = 1
        endfor
    endif
    if len(l:words) > 0
        let l:new_last_word = l:words[len(l:words)-1:][0]
        let s:last_word = l:new_last_word
    endif
endfunction

function! s:split_words(text)
    return  map(split(a:text, g:asyncomplete_buffer_identify_words_regex.'\zs'),'matchstr(v:val,g:asyncomplete_buffer_identify_words_regex)')
endfunction
