scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

call markdown_codehl_onthefly#start()

let &cpo = s:save_cpo
unlet s:save_cpo
