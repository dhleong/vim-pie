" Author: Daniel Leong<https://github.com/dhleong>
" Description: node-pie for vim-pie files

func! ale_linters#pie#node_pie#Handle(buffer, lines) abort

    let l:output = []

    for l:error in ale#util#FuzzyJSONDecode(a:lines, [])
        let l:item = {
        \   'type': get(l:error, 'severity', '') ==# 'error' ? 'E' : 'W',
        \   'text': l:error.message,
        \   'lnum': l:error.line,
        \   'col': l:error.column,
        \}

        call add(l:output, l:item)
    endfor

    return l:output
endfunc

call ale#linter#Define('pie', {
\   'name': 'node-pie',
\   'executable': 'node-pie',
\   'command': '%e lint -',
\   'callback': 'ale_linters#pie#node_pie#Handle',
\})
