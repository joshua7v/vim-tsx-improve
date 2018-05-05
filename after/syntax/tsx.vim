"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim syntax file
"
" Language: typescript.tsx
" Maintainer: Qiming <chemzqm@gmail.com> | joshua7v
" From https://raw.githubusercontent.com/neoclide/vim-jsx-improve/master/after/syntax/javascript.vim
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:tsx_cpo = &cpo
set cpo&vim

syntax case match

if exists('b:current_syntax')
  let s:current_syntax = b:current_syntax
  unlet b:current_syntax
endif

if exists('s:current_syntax')
  let b:current_syntax = s:current_syntax
endif

" <tag id="sample">
" s~~~~~~~~~~~~~~~e
syntax region tsxTag
      \ matchgroup=tsxTag start=+<[^ }/!?<>"'=:]\@=+
      \ matchgroup=tsxTag end=+\/\?>+
      \ contained
      \ contains=tsxTagName,tsxAttrib,tsxEqual,tsxString,tsxEscapeJsAttributes

" </tag>
" ~~~~~~
syntax match tsxEndTag
      \ +</[^ /!?<>"']\+>+
      \ contained
      \ contains=tsxEndString


"  <tag/>
" s~~~~~~e
syntax match tsxSelfClosingTag +<[^ /!?<>"'=:]\+\%(\%(=>\|[>]\@!\_.\)\)\{-}\/>+
      \ contained
      \ contains=tsxTag,@Spell
      \ transparent


"  <tag></tag>
" s~~~~~~~~~~~e
syntax region tsxRegion
      \ start=+\%(<\|\w\)\@<!<\z([^ /!?<>"'=:]\+\)+
      \ skip=+<!--\_.\{-}-->+
      \ end=+</\z1\_s\{-}>+
      \ end=+/>+
      \ fold
      \ contains=tsxSelfClosingTag,tsxRegion,tsxTag,tsxEndTag,tsxComment,tsxEntity,tsxEscapeJsContent,tsxString,@Spell
      \ keepend
      \ extend

syntax match tsxEndString
    \ +\w\++
    \ contained

" <!-- -->
" ~~~~~~~~
syntax match tsxComment /<!--\_.\{-}-->/ display

syntax match tsxEntity "&[^; \t]*;" contains=tsxEntityPunct
syntax match tsxEntityPunct contained "[&.;]"

" <tag key={this.props.key}>
"  ~~~
syntax match tsxTagName
    \ +[<]\@<=[^ /!?<>"']\++
    \ contained
    \ display

" <tag key={this.props.key}>
"      ~~~
syntax match tsxAttrib
    \ +[-'"<]\@<!\<[a-zA-Z:_][-.0-9a-zA-Z0-9:_]*\>\(['">]\@!\|\>\|$\)+
    \ contained
    \ contains=tsxAttribPunct,tsxAttribHook
    \ display

syntax match tsxAttribPunct +[:.]+ contained display

" <tag id="sample">
"        ~
syntax match tsxEqual +=+ contained display

" <tag id="sample">
"         s~~~~~~e
syntax region tsxString contained start=+"+ end=+"+ contains=tsxEntity,@Spell display

" <tag id='sample'>
"         s~~~~~~e
syntax region tsxString contained start=+'+ end=+'+ contains=tsxEntity,@Spell display

" <tag key={this.props.key}>
"          s~~~~~~~~~~~~~~e
syntax region tsxEscapeJsAttributes
    \ matchgroup=tsxAttributeBraces start=+{+
    \ matchgroup=tsxAttributeBraces end=+}\ze\%(\/\|\n\|\s\|<\|>\)+
    \ contained
    \ contains=TOP
    \ keepend
    \ extend

" <tag>{content}</tag>
"      s~~~~~~~e
syntax region tsxEscapeJsContent
    \ matchgroup=tsxAttributeBraces start=+{+
    \ matchgroup=tsxAttributeBraces end=+}+
    \ contained
    \ contains=TOP
    \ keepend
    \ extend

syntax match tsxIfOperator +?+
syntax match tsxElseOperator +:+

syntax cluster jsExpression add=tsxRegion,tsxSelfClosingTag

highlight def link tsxString String
highlight def link tsxNameSpace Function
highlight def link tsxComment Error
highlight def link tsxEscapeJsAttributes tsxEscapeJsAttributes

if hlexists('htmlTag')
  highlight def link tsxTagName htmlTagName
  highlight def link tsxEqual htmlTag
  highlight def link tsxAttrib htmlArg
  highlight def link tsxTag htmlTag
  highlight def link tsxEndTag htmlTag
  highlight def link tsxEndString htmlTagName
  highlight def link tsxAttributeBraces htmlTag
else
  highlight def link tsxTagName Statement
  highlight def link tsxEndString Statement
  highlight def link tsxEqual Function
  highlight def link tsxTag Function
  highlight def link tsxEndTag Function
  highlight def link tsxAttrib Type
  highlight def link tsxAttributeBraces Special
endif

let b:current_syntax = 'typescript.tsx'

if &ft == 'html'
  syn region  htmlScriptTag     contained start=+<script+ end=+>+ fold contains=htmlTagN,htmlString,htmlArg,htmlValue,htmlTagError,htmlEvent
endif

let &cpo = s:tsx_cpo
unlet s:tsx_cpo

