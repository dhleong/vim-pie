let s:split_cmds = {
    \ 'top': 'topleft',
    \ 'left': 'vertical topleft',
    \ 'right': 'vertical botright',
    \ 'bottom': 'botright',
    \ }

func! pie#win#Open() " {{{
    let openCmd = pie#Pref('open_mode')

    let m = matchlist(openCmd, '\v(\d*)(right|top|left|bottom)')
    if !len(m)
        echoerr 'Invalid pie_open_cmd: ' . openCmd

        " fallback to simple vsplit
        vsplit
        return
    endif

    let cmd = s:split_cmds[m[2]] . ' '

    if len(m[1])
        let cmd .= m[1]
    endif

    let cmd .= 'split'

    exe cmd
endfunc " }}}
