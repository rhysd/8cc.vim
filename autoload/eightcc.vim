let s:TARGET = map(split("vim\n", '\zs'), 'char2nr(v:val)')

function! eightcc#compile(...) abort
    let opts = a:0 > 0 ? a:1 : {}
    let opts = extend({
                \ 'input_type': 'buffer',
                \ 'output_type': 'buffer',
                \ }, opts)
    let verbose = has_key(opts, 'verbose') && opts.verbose && opts.output_type !=# 'echo'
    let debug = has_key(opts, '__debug')

    if verbose | echo 'Compiling C into EIR...' | endif
    if debug | let g:eightcc#__debug = {'config': opts} | endif

    let frontend = eightcc#frontend#create()
    let started = reltime()
    call frontend.run({
        \ 'input_type': opts.input_type,
        \ 'output_type': 'direct'
        \ })
    let spent = reltimestr(reltime(started, reltime()))

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
    if verbose | echo 'Compiling C into EIR: Success: ' . spent . 's' | endif
    if debug | let g:eightcc#__debug.spent_on_frontend =  spent | endif

    if debug | let g:eightcc#__debug.frontend = frontend | endif
    if verbose | echo 'Compiling EIR into Vim script...' | endif

    let backend = eightcc#backend#create()
    let started = reltime()
    call backend.run({
        \ 'input_type': 'direct',
        \ 'input': s:TARGET + frontend.output,
        \ 'output_type': opts.output_type,
        \ })
    let spent = reltimestr(reltime(started, reltime()))

    if verbose | echo 'Compiling EIR into Vim script: Success: ' . spent . 's' | endif
    if debug | let g:eightcc#__debug.spent_on_backend =  spent | endif
    if debug | let g:eightcc#__debug.backend = backend | endif

    return backend.output
endfunction
