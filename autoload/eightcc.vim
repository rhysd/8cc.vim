function! s:read_file(file) abort
    let lines = readfile(a:file, 'b')
    return map(split(join(lines, "\n"), '\zs'), 'char2nr(v:val)')
endfunction

function! eightcc#frontend(...) abort
    let opts = a:0 > 0 ? a:1 : {}
    let verbose = has_key(opts, 'verbose') && opts.verbose && opts.output_type !=# 'echo'
    let debug = has_key(opts, '__debug')

    if has_key(opts, 'lang') && opts.lang ==# 'eir'
        " Note: Fronend compiles into EIR. Nothing to do.
        return {}
    endif

    if debug | let g:eightcc#__debug.frontend_config = opts | endif
    if verbose | echo printf('Compiling C into EIR...') | endif

    let frontend = eightcc#frontend#create()
    let started = reltime()
    call frontend.run(opts)

    let spent = reltimestr(reltime(started, reltime()))
    if debug | let g:eightcc#__debug.spent_on_frontend =  spent | endif

    if has_key(frontend, 'lines') &&
        \ len(frontend.lines) > 0 &&
        \ stridx(frontend.lines[0], '[ERROR]') >= 0
        echohl ErrorMsg
        for l in frontend.lines
            echom l
        endfor
        echohl None
        return {}
    endif

    if verbose | echo 'Compiling C into EIR: Success: ' . spent . 's' | endif
    if debug | let g:eightcc#__debug.frontend = frontend | endif

    return frontend
endfunction

function! eightcc#backend(...) abort
    let opts = a:0 > 0 ? a:1 : {}
    let verbose = has_key(opts, 'verbose') && opts.verbose && opts.output_type !=# 'echo'
    let debug = has_key(opts, '__debug')

    " Note:
    " If 'target' is not specified, it assumes that target is already
    " specified in the first line of input.
    if has_key(opts, 'input') && has_key(opts, 'target')
        let opts.input = map(split(opts.target . "\n", '\zs'), 'char2nr(v:val)') + opts.input
    endif

    if debug | let g:eightcc#__debug.backend_config = opts | endif
    if verbose | echo 'Compiling eir into Vim script...' | endif

    let backend = eightcc#backend#create()
    try
        " Note:
        " Execute in binary mode because backend.run() may write out its output
        " to buffer.  Prevent automatically adding EOL to the end of buffer.
        let saved_bin = &binary
        set binary
        let started = reltime()
        call backend.run(opts)
        let spent = reltimestr(reltime(started, reltime()))
    finally
        let &binary = saved_bin
    endtry

    if verbose | echo 'Compiling EIR into Vim script: Success: ' . spent . 's' | endif

    if debug
        let g:eightcc#__debug.spent_on_backend = spent
        let g:eightcc#__debug.backend = backend
    endif

    return backend
endfunction

function! eightcc#compile(...) abort
    let opts = a:0 > 0 ? a:1 : {}
    let opts = extend({
                \ 'input_type': 'buffer',
                \ 'output_type': 'buffer',
                \ 'lang': 'c',
                \ 'target': 'vim',
                \ }, opts)

    if opts.input_type ==# 'file'
        let opts.input = s:read_file(opts.file)
        let opts.input_type = 'direct'
    endif

    " XXX
    let g:eightcc#__debug = {}

    if opts.lang ==# 'eir'
        return eightcc#backend(opts)
    endif

    let frontend = eightcc#frontend(
            \ extend(copy(opts), {'output_type': 'direct'})
            \ )

    if empty(frontend)
        " When failed
        return frontend
    endif

    return eightcc#backend(
            \ extend(copy(opts), {
            \ 'input_type': 'direct',
            \ 'input': frontend.output,
            \ })
        \ )
endfunction

function s:run_vimscript(lines, debug) abort
    let f = tempname()
    call writefile(a:lines, f, 'b')
    if a:debug | let g:eightcc#__debug.script = f | endif
    try
        execute 'source' f
        let vm = SetupVM()
        call vm.run()
    finally
        if !a:debug | call delete(f) | endif
    endtry
endfunction

function! eightcc#run(...) abort
    let opts = a:0 > 0 ? a:1 : {}
    let result = eightcc#compile(extend(opts, {'output_type': 'direct'}))
    if !has_key(result, 'lines')
        echohl ErrorMsg | echomsg 'Compiled result is empty!' | echohl None
    endif

    let verbose = has_key(opts, 'verbose') && opts.verbose
    if verbose | echo 'Running generated Vim script...' | endif
    call s:run_vimscript(result.lines, has_key(opts, '__debug'))
endfunction

