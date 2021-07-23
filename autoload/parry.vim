" parry.vim - Graceful pair handling
" Maintainer:   Zakhary Kaplan <https://zakharykaplan.ca>
" Version:      0.1.2
" SPDX-License-Identifier: Vim

" Get previous character before cursor
function! parry#PrevChar()
  return getline('.')[getpos('.')[2] - 2]
endfunction

" Get next character after cursor
function! parry#NextChar()
  return getline('.')[getpos('.')[2] - 1]
endfunction

" Get the current pair before and after cursor
function! parry#CurrentPair()
  return getline('.')[getpos('.')[2] - 2:getpos('.')[2] - 1]
endfunction

" Check if a character is a symmetrical pair
function! parry#IsSym(char)
  return has_key(g:Parried, a:char) && a:char == g:Parried[a:char]
endfunction

" Check if cursor is at a pair
function! parry#AtPair()
  " Create a regex of all pairs
  let regex = join(values(map(copy(g:Parried), {key, val -> key . val})), '\|')
  " Return whether the current pair is a match
  return parry#CurrentPair() =~# regex
endfunction

" Check if cursor is at a asymmetrical pair
function! parry#AtAsymPair()
  return parry#AtPair() && !parry#IsSym(parry#PrevChar())
endfunction

" Check if cursor is at a symmetrical pair
function! parry#AtSymPair()
  return parry#AtPair() && parry#IsSym(parry#PrevChar())
endfunction

" Check if cursor is within a string
function! parry#InString()
  let syngroups = join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'))
  return syngroups =~ 'string'
endfunction

" Check if closing pair should be added
function! parry#Parry(char)
  " Never close within a string
  if parry#InString()
    return 0
  endif

  " Get a string of all asymmetrical pair keys
  let keys = keys(filter(copy(g:Parried), 'v:key != v:val'))
  " Create a regex to match above keys
  let keys = '[' . substitute(join(keys, ''), ']', '\\]', 'g') . ']'
  " Get a string of all asymmetrical pair values
  let values = values(filter(copy(g:Parried), 'v:key != v:val'))
  " Create a regex to match above values
  let values = '[' . substitute(join(values, ''), ']', '\\]', 'g') . ']'

  " Use seperate rules for symmetrical pairs
  if parry#IsSym(a:char)
    return ((parry#PrevChar() !~# '\S') && (parry#NextChar() !~# '\S')) ||
         \ ((parry#PrevChar() =~# keys) && (parry#NextChar() =~# values))
  else
    return (parry#NextChar() !~# '\S') || (parry#NextChar() =~# values)
  endif
endfunction

" Handle <BS> within pair
function! parry#Backspace()
  return parry#AtPair() ? "\<BS>\<Del>" : "\<BS>"
endfunction

" Handle <CR> within pair
function! parry#Return()
  return parry#AtPair() ? "\<CR>\<Esc>ko" : "\<CR>"
endfunction

" Handle <Space> within pair
function! parry#Space()
  return parry#AtAsymPair() ? "\<Space>\<Space>\<Left>" : "\<Space>"
endfunction

" Automatically open a pair
function! parry#Open(char)
  return parry#Parry(a:char) ?
       \ a:char . g:Parried[a:char] . repeat("\<Left>", len(g:Parried[a:char])) :
       \ a:char
endfunction

" Automatically close a pair
function! parry#Close(char)
  if a:char == parry#NextChar()
    return "\<Right>"
  elseif parry#IsSym(a:char)
    return parry#Open(a:char)
  else
    return a:char
  endif
endfunction

" vim:fdl=0:fdm=indent:
