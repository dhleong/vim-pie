" ======= utils ===========================================

func! s:formatVar(k, v) " {{{
    let assign = '$' . a:k . ' = '
    if type(a:v) == type('')
        let assign .= '"' . escape(a:v, '"') . '"'
    elseif type(a:v) == type(0)
        let assign .= a:v
    endif
    return assign
endfunc " }}}


" ======= events ==========================================

func! s:handleNewVars(request, newVars) " {{{
    if !has_key(a:request, 'bufnr')
        return
    endif

    let bufnr = a:request.bufnr
    let lines = getbufline(bufnr, 1, '$')

    let newVars = a:newVars
    let i = 1
    for line in lines
        for [k, v] in items(newVars)
            let indentMatch = matchlist(line, '^\(\s*\)\$' . k)
            if len(indentMatch) > 1
                let indent = indentMatch[1]
                call setbufline(bufnr, i, indent . s:formatVar(k, v))
                unlet newVars[k]
                break
            endif
        endfo

        if empty(a:newVars)
            break
        endif

        let i = i + 1
    endfor
endfunc " }}}


" ======= event registration ==============================

let s:events = {
    \ 'new-vars': function('s:handleNewVars'),
    \ }


" ======= public interface ================================

func! pie#oob#HandleMessage(request, message) " {{{
    " Handle an OOB message relating to the given `request`

    let kind = a:message[0]
    let payload = a:message[1]

    if type(payload) == type(v:null) && payload == v:null
        " ignore
        return
    endif

    if has_key(s:events, kind)
        call s:events[kind](a:request, payload)
    endif
endfunc " }}}
