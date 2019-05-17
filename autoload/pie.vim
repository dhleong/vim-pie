
let s:pref_defaults = {
    \ 'open_mode': 'right',
    \ }

function! pie#Pref(prefName) " {{{
    let prefixed = 'pie_' . a:prefName
    return get(b:, prefixed,
        \ get(g:, prefixed, s:pref_defaults[a:prefName]))
endfunction " }}}
