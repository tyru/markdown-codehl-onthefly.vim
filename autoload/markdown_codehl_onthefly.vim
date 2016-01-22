scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


" let g:markdown_fenced_languages =
" \   map(globpath(&rtp, 'syntax/*', 1, 1), 'fnamemodify(v:val, ":t:r")')

" let g:markdown_fenced_languages =
" \   map(globpath(&rtp, 'syntax/*/', 1, 1) +
" \           globpath(&rtp, 'syntax/*.vim', 1, 1),
" \       'fnamemodify(v:val, ":t:r")')

" let g:markdown_fenced_languages = []
" let s:additionals = ['javascript', 'vim', 'viml=vim']
let s:additionals = []
let s:do_syn_include_after = 0

function! markdown_codehl_onthefly#set_fenced_langs() abort
    if &filetype !=# 'markdown'
        return
    endif
    if !exists('g:markdown_fenced_languages')
        let g:markdown_fenced_languages = []
    endif
    let g:markdown_fenced_languages =
    \   s:get_using_inline_filetypes() + s:additionals
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
        for filetype in s:get_using_inline_filetypes() + s:additionals
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
