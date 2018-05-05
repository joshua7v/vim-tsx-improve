"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim indent file
"
" Language: typescript.tsx
" Maintainer: Qiming <chemzqm@gmail.com>
" From https://raw.githubusercontent.com/neoclide/vim-tsx-improve/master/after/indent/typescript.vim
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:keepcpo = &cpo
set cpo&vim
let b:did_indent = 1

if !exists('*GetTypescriptIndent') | finish | endif

setlocal indentexpr=GettsxIndent()
setlocal indentkeys=0{,0},0),0],0\,,!^F,o,O,e,*<Return>,<>>,<<>,/

if exists('*shiftwidth')
  function! s:sw()
    return shiftwidth()
  endfunction
else
  function! s:sw()
    return &sw
  endfunction
endif

let s:real_endtag = '\s*<\/\+[A-Za-z]*>'
let s:return_block = '\s*return\s\+('
function! SynSOL(lnum)
  return map(synstack(a:lnum, 1), 'synIDattr(v:val, "name")')
endfunction

function! SynEOL(lnum)
  let lnum = prevnonblank(a:lnum)
  let col = strlen(getline(lnum))
  return map(synstack(lnum, col), 'synIDattr(v:val, "name")')
endfunction

function! SynAttrtsx(synattr)
  return a:synattr =~ "^tsx"
endfunction

function! SynXMLish(syns)
  return SynAttrtsx(get(a:syns, -1))
endfunction

function! SyntsxBlockEnd(syns)
  return get(a:syns, -1) =~ '\%(ts\|typescript\)Braces' ||
      \  SynAttrtsx(get(a:syns, -2))
endfunction

function! SyntsxDepth(syns)
  return len(filter(copy(a:syns), 'v:val ==# "tsxRegion"'))
endfunction

function! SyntsxCloseTag(syns)
  return len(filter(copy(a:syns), 'v:val ==# "tsxEndTag"'))
endfunction

function! SyntsxEscapeJs(syns)
  return len(filter(copy(a:syns), 'v:val ==# "tsxEscapeJs"'))
endfunction

function! SyntsxContinues(cursyn, prevsyn)
  let curdepth = SyntsxDepth(a:cursyn)
  let prevdepth = SyntsxDepth(a:prevsyn)

  return prevdepth == curdepth ||
      \ (prevdepth == curdepth + 1 && get(a:cursyn, -1) ==# 'tsxRegion')
endfunction

function! GettsxIndent()
  let cursyn  = SynSOL(v:lnum)
  let prevsyn = SynEOL(v:lnum - 1)
  let nextsyn = SynEOL(v:lnum + 1)
  let currline = getline(v:lnum)

  if ((SynXMLish(prevsyn) && SyntsxContinues(cursyn, prevsyn)) || currline =~# '\v^\s*\<')
    let preline = getline(v:lnum - 1)

    if currline =~# '\v^\s*\/?\>' " /> > 
      return preline =~# '\v^\s*\<' ? indent(v:lnum - 1) : indent(v:lnum - 1) - s:sw()
    endif

    if preline =~# '\v\{\s*$' && preline !~# '\v^\s*\<'
      return currline =~# '\v^\s*\}' ? indent(v:lnum - 1) : indent(v:lnum - 1) + s:sw()
    endif

    " return (      | return (     | return (
    "   <div></div> |   <div       |   <div
    "     {}        |     style={  |     style={
    "   <div></div> |     }        |     }
    " )             |     foo="bar"|   ></div>
    if preline =~# '\v\}\s*$'
      if currline =~# '\v^\s*\<\/'
        return indent(v:lnum - 1) - s:sw()
      endif
      let ind = indent(v:lnum - 1)
      if preline =~# '\v^\s*\<'
        let ind = ind + s:sw()
      endif
      if currline =~# '\v^\s*\/?\>'
        let ind = ind - s:sw()
      endif
      return ind
    endif

    " return ( | return (
    "   <div>  |   <div>
    "   </div> |   </div>
    " ##);     | );
    if preline =~# '\v(\s?|\k?)\($'
      return indent(v:lnum - 1) + s:sw()
    endif

    let ind = s:XmlIndentGet(v:lnum)

    " <div           | <div
    "   hoge={       |   hoge={
    "   <div></div>  |   ##<div></div>
    if SyntsxEscapeJs(prevsyn) && preline =~# '\v\{\s*$'
      let ind = ind + s:sw()
    endif

    " />
    if preline =~# '\v^\s*\/?\>$'
      "let ind = currline =~# '\v^\s*\<\/' ? ind : ind + s:sw()
      let ind = ind + s:sw()
    " }> or }}\> or }}>
    elseif preline =~# '\v^\s*\}?\}\s*\/?\>$'
      let ind = ind + s:sw()
    " ></a
    elseif preline =~# '\v^\s*\>\<\/\a'
      let ind = ind + s:sw()
    elseif preline =~# '\v^\s*}}.+\<\/\k+\>$'
      let ind = ind + s:sw()
    endif

    " <div            | <div
    "   hoge={        |   hoge={
    "     <div></div> |     <div></div>
    "     }           |   }##
    if currline =~# '}$' && !(currline =~# '\v\{')
      let ind = ind - s:sw()
    endif

    if currline =~# '^\s*)' && SyntsxCloseTag(prevsyn)
      let ind = ind - s:sw()
    endif
  else
    let ind = GetTypescriptIndent()
  endif
  return ind
endfunction

let b:xml_indent_open = '.\{-}<\a'
let b:xml_indent_close = '.\{-}</'

function! <SID>XmlIndentWithPattern(line, pat)
  let s = substitute('x'.a:line, a:pat, "\1", 'g')
  return strlen(substitute(s, "[^\1].*$", '', ''))
endfunction

" [-- return the sum of indents of a:lnum --]
function! <SID>XmlIndentSum(lnum, style, add)
  let line = getline(a:lnum)
  if a:style == match(line, '^\s*</')
    return (&sw *
          \  (<SID>XmlIndentWithPattern(line, b:xml_indent_open)
          \ - <SID>XmlIndentWithPattern(line, b:xml_indent_close)
          \ - <SID>XmlIndentWithPattern(line, '.\{-}/>'))) + a:add
  else
    return a:add
  endif
endfunction

function! <SID>XmlIndentGet(lnum)
  " Find a non-empty line above the current line.
  let lnum = prevnonblank(a:lnum - 1)

  " Hit the start of the file, use zero indent.
  if lnum == 0 | return 0 | endif

  let ind = <SID>XmlIndentSum(lnum, -1, indent(lnum))
  let ind = <SID>XmlIndentSum(a:lnum, 0, ind)
  return ind
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
