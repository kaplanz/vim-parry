" parry.vim - Graceful pair handling
" Maintainer:   Zakhary Kaplan <https://zakhary.dev>
" Version:      0.1.3
" SPDX-License-Identifier: Vim

" Setup: {{{
if exists("g:loaded_parry")
  finish
endif
let g:loaded_parry = 1
" }}}

" Options: {{{
if !exists('g:Parried')
  let g:Parried = {'(': ')', '[': ']', '{': '}',
                 \ "'": "'", '"': '"', '`': '`'}
endif
if !exists('g:parry_default_mappings')
  let g:parry_default_mappings = 1
endif
" }}}

" Autocmds: {{{
augroup Parry
  autocmd!
augroup END
" }}}

" Mappings: {{{
" Default mappings
inoremap <expr> <Plug>ParryBS    parry#bs()
inoremap <expr> <Plug>ParryCR    parry#cr()
inoremap <expr> <Plug>ParrySpace parry#space()
if g:parry_default_mappings
  imap <BS>    <Plug>ParryBS
  imap <CR>    <Plug>ParryCR
  imap <Space> <Plug>ParrySpace
endif
" Pair mappings
for [key, value] in items(g:Parried)
  " Map keys to parry#open
  let escaped_key = substitute(key, "'", "''", 'g')
  execute "inoremap <expr> ".key." parry#open('".escaped_key."')"

  " Map values to parry#close (overwrite symmetrical pairs)
  let escaped_value = substitute(value, "'", "''", 'g')
  execute "inoremap <expr> ".value." parry#close('".escaped_value."')"
endfor
" }}}

" vim:fdl=0:fdm=marker:
