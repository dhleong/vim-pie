func! s:OnEnterTermBuffer()
    " this is a one-off autocmd!
    augroup PieOutputWindow
        autocmd! * <buffer>
    augroup END

    " jump to the line between the headers and the body
    normal! gg}
endfunc

func! s:InOutputWindow(Block) " {{{
    " reuse an existing buffer/process
    let termBufNr = get(b:, '_pie_output_buf', -1)
    let termWinNr = bufwinnr(termBufNr)

    let mainBufNr = bufnr('%')
    let mainWinNr = bufwinnr(mainBufNr)

    if termWinNr == -1
        " open a new window for the term
        call pie#win#Open()
        enew

        let termBufNr = bufnr('%')
        call setbufvar(mainBufNr, '_pie_output_buf', termBufNr)

        setlocal nobuflisted

    else
        " switch to the term window
        exe termWinNr . 'wincmd w'
    endif

    " execute our block
    call a:Block()

    " if the bufnr changed, update it
    call setbufvar(mainBufNr, '_pie_output_buf', bufnr('%'))

    " set up the one-off on-enter autocmd
    augroup PieOutputWindow
        autocmd! * <buffer>
        autocmd BufEnter <buffer> call s:OnEnterTermBuffer()
    augroup END

    " switch back to the main window
    exe mainWinNr . 'wincmd w'
endfunc " }}}

func! s:StartSimpleTerm(request) " {{{
    let opts = {
        \ 'curwin': 1,
        \ 'out_modifiable': 0,
        \ 'norestore': 1,
        \ 'stoponexit': 'int',
        \ 'term_kill': 'int',
        \ 'term_name': 'Pie Output',
        \ }

    if get(a:request, 'debug', 0)
        let opts.env = { 'DEBUG': 'pie:*' }
    endif

    let cmd = 'node-pie exec '
    if has_key(a:request, 'file')
        let cmd .= a:request.file
    elseif has_key(a:request, 'bufnr')
        let cmd .= '-'
        let opts.in_io = 'buffer'
        let opts.in_buf = a:request.bufnr
    else
        throw 'Invalid request; must have `file` or `bufnr`'
    endif

    let cmd .= ' ' . a:request.line . ' --spinner'

    call term_start(cmd, opts)
endfunc " }}}

func! pie#runner#simple#Get()

    let runner = {
        \ 'requiresFile': 0,
        \ }
    func! runner.run(request)
        call s:InOutputWindow({-> s:StartSimpleTerm(a:request)})
    endfunc

    return runner
endfunc
