func! s:BuildRequestAt(runner, lineNr) " {{{
    let line = a:lineNr

    if !a:runner.requiresFile
        " we can just always use the bufnr!
        return { 'bufnr': bufnr('%'), 'line': line }
    endif

    if !&modified
        let file = expand('%:p')
        return { 'file': file, 'line': line }
    endif

    " If modified, we have to send the whole buffer. Future work could
    " try to guess where the request under this line ends to avoid
    " sending unnecessary stuff, but this is safer for now.
    " Since Vim hangs when the pipe buffer is full, we can't actually
    " send the buffer for even somewhat long files; instead we have to
    " write the buffer to a tmp file.
    " If job_start() could write the ANSI color to a normal buffer this
    " wouldn't be a problem...

    let tmp = tempname()
    call writefile(getline(1, '$'), tmp)

    return { 'file': tmp, 'line': line }
endfunc " }}}

func! pie#request#RunAt(lineNr) " {{{
    let runner = pie#runner#Get()

    let request = s:BuildRequestAt(runner, a:lineNr)
    if !has_key(request, 'line')
        echo 'Unable to create request'
        return
    endif

    call runner.run(request)
endfunc " }}}

func! pie#request#RunUnderCursor() " {{{
    call pie#request#RunAt(line('.'))
endfunc " }}}
