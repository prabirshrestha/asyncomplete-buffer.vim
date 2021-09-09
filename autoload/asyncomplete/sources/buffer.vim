let s:words = {}
let g:asyncomplete_buffer_clear_cache = get(g:, 'asyncomplete_buffer_clear_cache', 1)

function! asyncomplete#sources#buffer#completor(opt, ctx)
    let l:typed = a:ctx['typed']

    if empty(s:words)
        return
    endif

    let l:matches = []

    let l:col = a:ctx['col']

    let l:kw = matchstr(l:typed, '\w\+$')
    let l:kwlen = len(l:kw)

    let l:matches = map(keys(s:words),'{"word":v:val,"dup":1,"icase":1,"menu": "[buffer]"}')
    let l:startcol = l:col - l:kwlen

    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
endfunction

function! asyncomplete#sources#buffer#get_source_options(opts)
    return extend({
        \ 'events': ['BufWinEnter', 'TextChangedI', 'InsertLeave'],
        \ 'on_event': function('s:on_event'),
        \}, a:opts)
endfunction

function! s:should_ignore(opt) abort
    let l:max_buffer_size = 5000000 " 5mb
    if has_key(a:opt, 'config') && has_key(a:opt['config'], 'max_buffer_size')
        let l:max_buffer_size = a:opt['config']['max_buffer_size']
    endif
    if l:max_buffer_size != -1
        let l:buffer_size = line2byte(line('$') + 1)
        if l:buffer_size > l:max_buffer_size
            call asyncomplete#log('asyncomplete#sources#buffer', 'ignoring buffer autocomplete due to large size', expand('%:p'), l:buffer_size)
            return 1
        endif
    endif

    return 0
endfunction

function! s:on_event(opt, ctx, event) abort
    if s:should_ignore(a:opt) | return | endif

    if a:event ==# 'BufWinEnter'
        call s:refresh_keywords()
    elseif a:event ==# 'TextChangedI'
        let l:typed = a:ctx['typed']
        if empty(l:typed) " may be a new line, so add the prev line
            call s:add_line(getline(a:ctx['lnum'] - 1))
        elseif match(l:typed, '\W$') > -1 " ends with a non-word char, add the typed text
            call s:add_line(l:typed)
        endif
    elseif a:event ==# 'InsertLeave'
        call s:add_line(getline('.'))
    endif
endfunction

function! s:refresh_keywords() abort
    if g:asyncomplete_buffer_clear_cache
        let s:words = {}
    endif
    let l:line = join(getline(1,'$'), "\n")
    call s:add_line(l:line)
    call asyncomplete#log('asyncomplete#buffer', 's:refresh_keywords() complete')
endfunction

function! s:add_line(line) abort
    for l:word in split(a:line, '\W\+')
        if len(l:word) > 1
            let s:words[l:word] = 1
        endif
    endfor
endfunction
