let s:TARGET = map(split("vim\n", '\zs'), 'char2nr(v:val)')

function! eightcc#compile(...) abort
    let opts = a:0 > 0 ? a:1 : {}
    let opts = extend({
                \ 'input_type': 'buffer',
                \ 'output_type': 'buffer',
                \ }, opts)
    let verbose = has_key(opts, 'verbose') && opts.verbose && opts.output_type !=# 'echo'
    let debug = has_key(opts, '__debug')

    if verbose
        echo 'Compiling to EIR...'
    endif
    if debug
        let g:eightcc#__debug = {'config': opts}
    endif

    let frontend = eightcc#frontend#create()
    call frontend.run({
        \ 'input_type': opts.input_type,
        \ 'output_type': 'direct'
        \ })

    if has_key(frontend, 'lines') &&
        \ len(frontend.lines) > 0 &&
        \ stridx(frontend.lines[0], '[ERROR]') >= 0
        echohl ErrorMsg
        for l in frontend.lines
            echom l
        endfor
        echohl None
        return 1
    endif

    let frontend.output = s:TARGET + frontend.output

    if debug
        let g:eightcc#__debug.frontend = frontend
    endif

    if verbose
        echo 'Compiling to Vim script...'
    endif

    let backend = eightcc#backend#create()
    call backend.run({
        \ 'input_type': 'direct',
        \ 'input': frontend.output,
        \ 'output_type': opts.output_type,
        \ })

    if debug
        let g:eightcc#__debug.backend = backend
    endif

    return backend.output
endfunction
