if (exists('g:loaded_eightcc') && g:loaded_eightcc) || &cp
    finish
endif

command! -nargs=* -count -bang -complete=customlist,eightcc#command#complete
                \ EccCompile call eightcc#command#compile(<q-args>, <count>, <q-bang>)

command! -nargs=* -count -bang -complete=customlist,eightcc#command#complete
                \ EccRun call eightcc#command#run(<q-args>, <count>, <q-bang>)

let g:loaded_eightcc = 1
