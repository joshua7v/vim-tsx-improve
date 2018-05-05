"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim ftplugin file
"
" Language: typescript.tsx
" Maintainer: Qiming <chemzqm@gmail.com>
" From https://raw.githubusercontent.com/neoclide/vim-tsx-improve/master/after/ftplugin/typescript.vim
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Make matchit support tsx
if exists("loaded_matchit")
  let b:match_ignorecase = 0
  let b:match_words = '(:),\[:\],{:},<:>,' .
        \ '<\@<=\([^/][^ \t>]*\)\%(/\@<!>\|$\|[ \t][^>]*\%(/\@<!>\|$\)\):<\@<=/\1>'
endif

" Automatic gf
setlocal iskeyword+=$ suffixesadd+=.ts

if get(g:, "tsx_improve_motion_disable") != 1
  nnoremap <buffer> <silent> [[ :call <SID>GotoSection(0,1)<cr>
  nnoremap <buffer> <silent> ][ :call <SID>GotoSection(1,1)<cr>
  nnoremap <buffer> <silent> [] :call <SID>GotoSection(0,0)<cr>
  nnoremap <buffer> <silent> ]] :call <SID>GotoSection(1,0)<cr>

  function! s:GotoSection(forward, open)
    let l:d = a:forward ? 1 : -1
    let nr = line('.') + l:d
    let total = line('$')
    let l:match = a:open ? '{$' : '^\s*}'
    while nr !=# -1
      let line = getline(nr)
      if line =~# l:match
        let col = matchend(line, l:match)
        if synIDattr(synID(nr, col, 1),"name") ==# 'tsFuncBraces'
          break
        endif
      endif
      let nr = nr + l:d
      " not found
      if nr == 0 | let nr = -1 | endif
      if nr == total + 1 | let nr = -1 | endif
    endw
    if nr == -1 | return | endif
    execute "normal! " . nr . "G" . (a:open ? '$' : '^')
  endfunction
endif

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= ' | setlocal iskeyword< suffixesadd<'
else
  let b:undo_ftplugin = 'setlocal iskeyword< suffixesadd<'
endif

