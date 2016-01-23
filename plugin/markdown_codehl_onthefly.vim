scriptencoding utf-8

if exists('g:loaded_markdown_codehl_onthefly')
  finish
endif
let g:loaded_markdown_codehl_onthefly = 1

let s:save_cpo = &cpo
set cpo&vim


augroup markdown_codehl_onthefly-bootstrap
    autocmd!
    autocmd FileType markdown
    \   call markdown_codehl_onthefly#start()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set et:
