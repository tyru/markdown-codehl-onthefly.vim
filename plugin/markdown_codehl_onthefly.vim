scriptencoding utf-8

if exists('g:loaded_stoptypofile')
  finish
endif
let g:loaded_stoptypofile = 1

let s:save_cpo = &cpo
set cpo&vim


augroup markdown_codehl_onthefly
    autocmd!
    autocmd FileType markdown
    \   call markdown_codehl_onthefly#set_fenced_langs()
    autocmd TextChanged,TextChangedI *
    \   call markdown_codehl_onthefly#do_syn_include_after()
    autocmd InsertLeave *
    \   call markdown_codehl_onthefly#syn_include_dynamically()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set et:
