let s:V = vital#8cc#new()
let s:O = s:V.import('OptionParser')
let s:parser = s:O.new()

function! s:complete_lang(optlead, cmdline, cursorpos) abort
    return filter(['c', 'eir'],
        \ 'a:optlead == "" ? 1 : (v:val =~# a:optlead)')
endfunction

" From https://github.com/shinh/elvm/tree/master/target
function! s:complete_target(optlead, cmdline, cursorpos) abort
    return filter(['rb', 'py', 'vim', 'c', 'el', 'bf', 'bef', 'i', 'java', 'js', 'piet', 'sh', 'unl', 'ws', 'x86'],
        \ 'a:optlead == "" ? 1 : (v:val =~# a:optlead)')
endfunction

" Define options
call s:parser.on('--buffer', 'Input from current buffer', {'short': '-b'})
            \.on('--file=VALUE', 'Input from file', {'completion': 'file'})
            \.on('--getchar', 'Input from getchar()')
            \.on('--target=LANG', 'Output language',
                \ {'short': '-t', 'completion': function('s:complete_target')})
            \.on('--lang=LANG', 'Input language (one of "c" or "eir")',
                \ {'short': '-l', 'completion': function('s:complete_lang')})
            \.on('--echo', 'Output the result with :echo')
            \.on('--verbose', ':echo the progress of compilation')
            \.on('--debug', 'Dump debug information to g:eightcc#__debug')

" Prepare for a completion function
function! eightcc#command#complete(arglead, cmdline, cursorpos) abort
    return s:parser.complete(a:arglead, a:cmdline, a:cursorpos)
endfunction

function! s:convert_to_opts(parsed) abort
    let ret = {}

    if has_key(a:parsed, 'file')
        let ret.input_type = 'file'
        let ret.file = a:parsed.file
    elseif has_key(a:parsed, 'buffer')
        let ret.input_type = 'buffer'
    elseif has_key(a:parsed, 'getchar')
        let ret.input_type = 'getchar'
    endif

    if has_key(a:parsed, 'echo')
        let ret.output_type = 'echo'
    endif

    if has_key(a:parsed, 'verbose')
        let ret.verbose = 1
    endif

    if has_key(a:parsed, 'debug')
        let ret.__debug = 1
    endif

    return ret
endfunction

function! s:should_cancel(parsed) abort
    if has_key(a:parsed, 'help')
        return 1
    endif

    if len(a:parsed.__unknown_args__) > 0
        echohl ErrorMsg
        echom 'Unknown options ' . join(map(a:parsed.__unknown_args__, 'string(v:val)'), ', ') . '. Please try --help option.'
        echohl None
        return 1
    endif

    return 0
endfunction

function! eightcc#command#compile(qargs, count, qbang) abort
    let parsed = s:parser.parse(a:qargs, a:count, a:qbang)
    if s:should_cancel(parsed)
        return
    endif
    call eightcc#compile(s:convert_to_opts(parsed))
endfunction

function! eightcc#command#run(qargs, count, qbang) abort
    let parsed = s:parser.parse(a:qargs, a:count, a:qbang)
    if s:should_cancel(parsed)
        return
    endif
    call eightcc#run(s:convert_to_opts(parsed))
endfunction
