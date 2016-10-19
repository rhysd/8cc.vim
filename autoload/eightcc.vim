function! s:read_file(file) abort
    let opts = a:0 > 0 ? a:1 : {}

    try
        let saved_bin = &binary
        set binary
        let lines = readfile(a:file, 'b')
    finally
        let &binary = saved_bin
    endtry

    return map(split(join(lines, "\n"), '\zs'), 'char2nr(v:val)')
endfunction

" TODO:
" Split running frontend and backend into functions
function! eightcc#compile(...) abort
    let opts = a:0 > 0 ? a:1 : {}
    let opts = extend({
                \ 'input_type': 'buffer',
                \ 'output_type': 'buffer',
                \ }, opts)

    if opts.input_type ==# 'file'
        let opts.input = s:read_file(opts.file)
        let opts.input_type = 'direct'
    endif

    let verbose = has_key(opts, 'verbose') && opts.verbose && opts.output_type !=# 'echo'
    let debug = has_key(opts, '__debug')

    if verbose | echo 'Compiling C into EIR...' | endif
    if debug | let g:eightcc#__debug = {'config': opts} | endif

    let frontend_opts = {
        \ 'input_type': opts.input_type,
        \ 'output_type': 'direct'
        \ }
    if has_key(opts, 'input')
        let frontend_opts.input = opts.input
    endif

    let frontend = eightcc#frontend#create()
    let started = reltime()
    call frontend.run(frontend_opts)
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

    let target = has_key(a:config, 'target') ? a:config.target : 'vim'
    let input = map(split(target . "\n", '\zs'), 'char2nr(v:val)') + frontend.output

    let backend = eightcc#backend#create()
    try
        let saved_bin = &binary
        set binary
        let started = reltime()
        call backend.run({
            \ 'input_type': 'direct',
            \ 'input': input,
            \ 'output_type': opts.output_type,
            \ })
        let spent = reltimestr(reltime(started, reltime()))
    finally
        let &binary = saved_bin
    endtry

    if verbose | echo 'Compiling EIR into Vim script: Success: ' . spent . 's' | endif
    if debug | let g:eightcc#__debug.spent_on_backend =  spent | endif
    if debug | let g:eightcc#__debug.backend = backend | endif

    return backend
endfunction

function s:run_vimscript(lines) abort
    let f = tempname()
    call writefile(a:lines, f, 'b')
    try
        execute 'source' f
        let c = CreateCompiler()
        call c.run()
    finally
        call delete(f)
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
    call s:run_vimscript(result.lines)
endfunction
