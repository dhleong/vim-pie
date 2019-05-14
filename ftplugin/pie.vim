func! s:mapPlug(mode, defaultMapping, plugName)
    if !hasmapto(a:plugName, a:mode) && !mapcheck(a:defaultMapping, a:mode)
        exe a:mode . 'map <buffer>' a:defaultMapping a:plugName
    endif
endfunc

nnoremap <silent> <Plug>PieRun :<C-U>call pie#request#RunUnderCursor()<cr>

call s:mapPlug('n', '<cr>', '<Plug>PieRun')
