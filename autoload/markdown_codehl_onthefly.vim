scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let g:markdown_codehl_onthefly#additional_fenced_languages =
\   get(g:, 'markdown_codehl_onthefly#additional_fenced_languages', [
\           'viml=vim'
\])

let s:do_syn_include_after = 0


function! markdown_codehl_onthefly#set_fenced_langs() abort
    if &filetype !=# 'markdown'
        return
    endif
    call s:save_markdown_fenced_languages()
    if !exists('g:markdown_fenced_languages')
        let g:markdown_fenced_languages = []
    endif
    let g:markdown_fenced_languages =
    \   s:get_using_inline_filetypes() +
    \   g:markdown_codehl_onthefly#additional_fenced_languages
endfunction

function! s:save_markdown_fenced_languages() abort
    if !exists('g:markdown_fenced_languages')
        return
    endif
    " Tooooo loooooooooooooooong
    let b:markdown_codehl_onthefly_markdown_fenced_languages =
    \       g:markdown_fenced_languages
endfunction

function! markdown_codehl_onthefly#restore_markdown_fenced_languages() abort
    if !exists('b:markdown_codehl_onthefly_markdown_fenced_languages')
        return
    endif
    let g:markdown_fenced_languages =
    \   b:markdown_codehl_onthefly_markdown_fenced_languages
endfunction

function! markdown_codehl_onthefly#do_syn_include_after() abort
    let s:do_syn_include_after = 1
endfunction

function! markdown_codehl_onthefly#syn_include_dynamically() abort
    if !s:do_syn_include_after
        return
    endif
    if !exists('g:markdown_fenced_languages')
        let g:markdown_fenced_languages = []
    endif
    try
        let added = 0
        for filetype in s:get_using_inline_filetypes() +
        \   g:markdown_codehl_onthefly#additional_fenced_languages
            let group = 'markdownHighlight' . filetype
            if match(g:markdown_fenced_languages,
            \       '\(^\|=\)'.filetype.'$') ==# -1
                let g:markdown_fenced_languages += [filetype]
                let added = 1
            endif
        endfor
        if added
            syntax clear
            syntax enable
        endif
    finally
        let s:do_syn_include_after = 0
    endtry
endfunction

let s:RE_FILETYPE = '```\zs\w\+\ze'
function! s:get_using_inline_filetypes() abort
    return map(filter(getline(1, '$'), 'v:val =~# s:RE_FILETYPE'),
    \         'matchstr(v:val, s:RE_FILETYPE)')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set et:
