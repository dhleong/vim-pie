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

func! s:SendToJob(job, jsonable) " {{{
    let job = a:job

    let encoded = json_encode(a:jsonable)

    call ch_sendraw(job, encoded . "\n")
endfunc " }}}

func! pie#runner#Get()
    let job = s:GetTermJob()
    if job == v:null
        throw "Error: no job"
    endif

    let runner = {}
    func! runner.run(request) closure
        call s:SendToJob(job, a:request)
    endfunc

    return runner
endfunc
