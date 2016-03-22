scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


if !exists('g:markdown_codehl_onthefly#additional_fenced_languages')
    let g:markdown_codehl_onthefly#additional_fenced_languages = []
    " From linguist's languages.yml
    " https://github.com/github/linguist/blob/master/lib/linguist/languages.yml
    for [alias, to] in [
    \   ['viml', 'vim'],
    \   ['nvim', 'vim'],
    \   ['bash', 'sh'],
    \   ['zsh', 'sh'],
    \   ['rusthon', 'python'],
    \   ['jruby', 'ruby'],
    \   ['macruby', 'ruby'],
    \   ['rake', 'ruby'],
    \   ['rb', 'ruby'],
    \   ['rbx', 'ruby'],
    \   ['json', 'javascript'],
    \   ['js', 'javascript'],
    \   ['node', 'javascript'],
    \]
        " If <alias>.vim is not installed, add to additional languages.
        if globpath(&rtp, 'syntax/' . alias . '.vim') ==# ''
            let g:markdown_codehl_onthefly#additional_fenced_languages +=
            \   [alias . '=' . to]
        endif
    endfor
endif

let s:NONE = []
let s:do_syn_include_after = 0


function! markdown_codehl_onthefly#start() abort
    if &filetype !=# 'markdown'
        return
    endif
    " Save current g:markdown_fenced_languages
    call s:save_markdown_fenced_languages()
    " Change g:markdown_fenced_languages (buffer-local)
    call s:add_markdown_fenced_languages(
    \   g:markdown_codehl_onthefly#additional_fenced_languages +
    \   s:get_using_inline_langs())
    " Register auto-commands (buffer-local)
    augroup markdown_codehl_onthefly-buflocal
        autocmd!
        autocmd TextChanged,TextChangedI <buffer>
        \   let s:do_syn_include_after = 1
        autocmd InsertLeave <buffer>
        \   call s:syn_include_dynamically()
        autocmd BufEnter <buffer>
        \   call s:restore_buflocal_markdown_fenced_languages()
        autocmd BufLeave <buffer>
        \   call s:restore_markdown_fenced_languages()
    augroup END
endfunction

" Save current g:markdown_fenced_languages
" before changing g:markdown_fenced_languages.
" @seealso s:restore_markdown_fenced_languages()
function! s:save_markdown_fenced_languages() abort
    if !exists('g:markdown_fenced_languages')
        let b:markdown_codehl_onthefly_prev_markdown_fenced_languages =
        \   s:NONE
    else
        let b:markdown_codehl_onthefly_prev_markdown_fenced_languages =
        \   g:markdown_fenced_languages
    endif
endfunction

" Restore original g:markdown_fenced_languages
" before entering markdown buffer.
" @seealso s:save_markdown_fenced_languages()
function! s:restore_markdown_fenced_languages() abort
    if b:markdown_codehl_onthefly_prev_markdown_fenced_languages is s:NONE
        unlet g:markdown_fenced_languages
    else
        let g:markdown_fenced_languages =
        \   b:markdown_codehl_onthefly_prev_markdown_fenced_languages
    endif
endfunction

" Set g:markdown_fenced_languages when entering markdown buffer.
" @seealso s:restore_buflocal_markdown_fenced_languages()
function! s:add_markdown_fenced_languages(langs) abort
    if !exists('g:markdown_fenced_languages')
        let g:markdown_fenced_languages = []
    endif
    " 1. {lang}
    " 2. {lang}=...
    let added = 0
    for lang in a:langs
        let alias = matchstr(lang, '^[^=]\+')
        let syntax = lang =~# '=' ? matchstr(lang, '=\zs.\+') : alias
        if alias !=# '' &&
        \   match(g:markdown_fenced_languages,
        \       '^'.alias.'\($\|=\)') ==# -1 &&
        \   globpath(&rtp, 'syntax/' . syntax . '.vim') !=# ''
            let g:markdown_fenced_languages += [lang]
            let added = 1
        endif
    endfor
    let b:markdown_codehl_onthefly_buflocal_markdown_fenced_languages =
    \   copy(g:markdown_fenced_languages)
    return added
endfunction

" Set g:markdown_fenced_languages when entering markdown buffer.
" @seealso s:add_markdown_fenced_languages()
function! s:restore_buflocal_markdown_fenced_languages() abort
    if exists('b:markdown_codehl_onthefly_buflocal_markdown_fenced_languages')
        let g:markdown_fenced_languages =
        \   b:markdown_codehl_onthefly_buflocal_markdown_fenced_languages
    endif
endfunction

function! s:syn_include_dynamically() abort
    if !s:do_syn_include_after
        return
    endif
    if !exists('g:markdown_fenced_languages')
        let g:markdown_fenced_languages = []
    endif
    try
        if s:add_markdown_fenced_languages(s:get_using_inline_langs())
            syntax clear
            syntax enable
        endif
    finally
        let s:do_syn_include_after = 0
    endtry
endfunction

let s:RE_FILETYPE = '```\zs\w\+\ze'
function! s:get_using_inline_langs() abort
    return map(filter(getline(1, '$'), 'v:val =~# s:RE_FILETYPE'),
    \         'tolower(matchstr(v:val, s:RE_FILETYPE))')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set et:
