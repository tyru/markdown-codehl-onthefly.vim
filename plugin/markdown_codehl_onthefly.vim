scriptencoding utf-8

if exists('g:loaded_markdown_codehl_onthefly')
  finish
endif
let g:loaded_markdown_codehl_onthefly = 1

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
    autocmd BufLeave *
    \   call markdown_codehl_onthefly#restore_markdown_fenced_languages()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set et:
