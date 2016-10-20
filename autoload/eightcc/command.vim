let s:V = vital#8cc#new()
let s:O = s:V.import('OptionParser')
let s:parser = s:O.new()

function! s:complete_lang(optlead, cmdline, cursorpos)
return filter(['c', 'eir'],
        \ 'a:optlead == "" ? 1 : (v:val =~# a:optlead)')
endfunction

" From https://github.com/shinh/elvm/tree/master/target
function! s:complete_target(optlead, cmdline, cursorpos)
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
            \.on('--verbose', ':echo the progress of compilation')
            \.on('--debug', 'Dump debug information to g:eightcc#__debug')

" Prepare for a completion function
function! eightcc#command#complete(arglead, cmdline, cursorpos)
return s:parser.complete(a:arglead, a:cmdline, a:cursorpos)
endfunction

function! eightcc#command#run(qargs, count, qbang) abort
    let parsed = s:parser.parse(a:qargs, a:count, a:qbang)
    echo parsed
    throw 'Not implemented yet!'
endfunction

