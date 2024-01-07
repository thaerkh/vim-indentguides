" Vim plugin
" Author:  Thaer Khawaja
" License: Apache 2.0
" URL:     https://github.com/thaerkh/vim-indentguides

let g:indentguides_firstlevel = get(g:, 'indentguides_firstlevel', 0)
let g:indentguides_ignorelist = get(g:, 'indentguides_ignorelist', ['asciidoc', 'gitcommit', 'markdown', 'tex', 'text', ''])
let g:indentguides_spacechar = get(g:, 'indentguides_spacechar', '┆')
let g:indentguides_tabchar = get(g:, 'indentguides_tabchar', '|')
let g:indentguides_toggleListMode = get(g:, 'indentguides_toggleListMode', 1)
let g:indentguides_guidewidth = get(g:, 'indentguides_guidewidth', &l:shiftwidth)
let g:indentguides_conceal_color = get(g:, 'indentguides_conceal_color', 'ctermfg=238 ctermbg=NONE guifg=Grey27 guibg=NONE')
let g:indentguides_specialkey_color = get(g:, 'indentguides_specialkey_color',  'ctermfg=238 ctermbg=NONE guifg=Grey27 guibg=NONE')

function! s:SetIndentGuideHighlights(user_initiated)
  if index(g:indentguides_ignorelist, &filetype) == -1 || a:user_initiated
    if !a:user_initiated
      silent! syntax clear IndentGuideSpaces
      silent! syntax clear IndentGuideDraw
    endif
    execute "highlight Conceal " . g:indentguides_conceal_color
    execute "highlight SpecialKey " . g:indentguides_specialkey_color

    if g:indentguides_firstlevel
      execute printf('syntax match IndentGuideDraw /^\zs\ \ze\ \{%i}/ containedin=ALL conceal cchar=', g:indentguides_guidewidth - 1) . g:indentguides_spacechar
    endif
    execute 'syntax match IndentGuideSpaces /^\ \+/ containedin=ALL contains=IndentGuideDraw keepend'
    execute printf('syntax match IndentGuideDraw /\ \{%i}\zs \ze/ contained conceal cchar=', g:indentguides_guidewidth - 1) . g:indentguides_spacechar
  endif
endfunction

function! s:ToggleIndentGuides(user_initiated)
  let b:toggle_indentguides = get(b:, 'toggle_indentguides', 1)
  let g:indentguides_guidewidth = &l:shiftwidth

  if !a:user_initiated
    if index(g:indentguides_ignorelist, &filetype) != -1 || !b:toggle_indentguides
      " skip if not user initiated, and is either disabled, an ignored filetype, or already toggled on
      return
    endif
  endif

  if b:toggle_indentguides
    call s:SetIndentGuideHighlights(a:user_initiated)

    " TODO-TK: local and global listchars are the same, and s: variables are failing (??)
    let g:original_listchars = get(g:, 'original_listchars', &g:listchars)

    " TODO: figure out why checking each addition individually breaks things for tab (unicode?)
    let listchar_guides = 'tab:' . g:indentguides_tabchar . ' ,'
    if &g:listchars !~ listchar_guides
      let &g:listchars = listchar_guides . &g:listchars
    endif
    if &conceallevel == 0 || &conceallevel == 3
      setlocal conceallevel=2
    endif
    if &concealcursor ==# '' && !exists('g:indentguides_concealcursor_unaltered')
      setlocal concealcursor=inc
    endif
    if g:indentguides_toggleListMode
      setlocal list
    endif
    let b:toggle_indentguides = 0
  else
    syntax clear IndentGuideSpaces
    syntax clear IndentGuideDraw

    let &l:conceallevel = &g:conceallevel
    let &l:concealcursor = &g:concealcursor
    let &g:listchars = g:original_listchars
    if g:indentguides_toggleListMode
      setlocal nolist
    endif
    let b:toggle_indentguides = 1
  endif
endfunction

augroup IndentGuides
  au! BufRead,ColorScheme * call s:SetIndentGuideHighlights(0)
  au! BufWinEnter * call s:ToggleIndentGuides(0)
augroup END

command! IndentGuidesToggle call s:ToggleIndentGuides(1)

" vim: ts=2 sw=2 et
