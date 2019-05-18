func! s:OnEnterTermBuffer() " {{{

    " enter term-normal mode immediately
    call feedkeys("i\<bs>\<c-w>N", 'n')

    " NOTE: the extra i\<bs> above ensures we're properly focused,
    " and works around an apparent vim bug where the *second* time
    " we enter the buffer like this the normal mode appears empty

    " NOTE: if we don't use a delay like this, vim seems
    " to get stuck in a weird 'input pending'-like mode
    call timer_start(1, { -> feedkeys("gg", 'n') })
endfunc " }}}

func! s:OnLeaveTermBuffer() " {{{
    " return to term-job mode
    silent! normal i
endfunc " }}}

func! s:OnLeavePieBufWin() " {{{
    let termBufNr = get(b:, '_pie_output_buf', -1)
    if termBufNr == -1
        " nothing to do
        return
    endif

    " stop the daemon to close the term window
    let job = term_getjob(termBufNr)
    if job != v:null
        call job_stop(job, 'int')
    endif
endfunc " }}}

func! s:GetTermJob() " {{{
    let cmd = 'node-pie daemon'

    " reuse an existing buffer/process
    let termBufNr = get(b:, '_pie_output_buf', -1)
    let termWinNr = bufwinnr(termBufNr)

    if termWinNr == -1
        let mainBufNr = bufnr('%')
        let mainWinNr = bufwinnr(mainBufNr)

        " open a new window for the term
        call pie#win#Open()

        let termBufNr = term_start(cmd, {
            \ 'curwin': 1,
            \ 'in_io': 'pipe',
            \ 'out_modifiable': 0,
            \ 'norestore': 1,
            \ 'stoponexit': 'int',
            \ 'term_finish': 'close',
            \ 'term_kill': 'int',
            \ 'term_name': 'Pie Output',
            \ })
        let termBufNr = bufnr('%')
        call setbufvar(mainBufNr, '_pie_output_buf', termBufNr)

        au BufEnter <buffer> call s:OnEnterTermBuffer()
        au BufLeave <buffer> call s:OnLeaveTermBuffer()
        setlocal nobuflisted

        " switch back to the main window
        exe mainWinNr . 'wincmd w'

        au BufWinLeave <buffer> call s:OnLeavePieBufWin()
    endif

    return term_getjob(termBufNr)
endfunc " }}}

func! s:BuildRequestAt(lineNr) " {{{
    let line = a:lineNr

    if !&modified
        let file = expand('%:p')
        return { 'file': file, 'line': line }
    endif

    " If modified, we have to send the whole buffer. Future work could
    " try to guess where the request under this line ends to avoid
    " sending unnecessary stuff, but this is safer for now:

    return {
        \ 'lines': getline(1, '$'),
        \ 'line': line,
        \ }
endfunc " }}}

func! pie#request#RunAt(lineNr) " {{{
    let job = s:GetTermJob()
    if job == v:null
        echo "Error: no job"
        return
    endif

    let request = s:BuildRequestAt(a:lineNr)
    if !has_key(request, 'line')
        echo "Unable to create request"
        return
    endif

    call ch_sendraw(job, json_encode(request) . "\n")
endfunc " }}}

func! pie#request#RunUnderCursor() " {{{
    call pie#request#RunAt(line('.'))
endfunc " }}}
