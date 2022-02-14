" parry.vim - Graceful pair handling
" Maintainer:   Zakhary Kaplan <https://zakhary.dev>
" Version:      0.1.3
" SPDX-License-Identifier: Vim

" Handle <BS> within pair
function! parry#bs()
  return s:AtPair() ? "\<BS>\<Del>" : "\<BS>"
endfunction

" Handle <CR> within pair
function! parry#cr()
  return s:AtPair() ? "\<CR>\<Esc>ko" : "\<CR>"
endfunction

" Handle <Space> within pair
function! parry#space()
  return s:AtAsymPair() ? "\<Space>\<Space>\<Left>" : "\<Space>"
endfunction

" Automatically open a pair
function! parry#open(char)
  return s:Parry(a:char) ?
       \ a:char . g:Parried[a:char] . repeat("\<Left>", len(g:Parried[a:char])) :
       \ a:char
endfunction

" Automatically close a pair
function! parry#close(char)
  if a:char == s:NextChar()
    return "\<Right>"
  elseif s:IsSym(a:char)
    return parry#open(a:char)
  else
    return a:char
  endif
endfunction

" Get previous character before cursor
function! s:PrevChar()
  return getline('.')[getpos('.')[2] - 2]
endfunction

" Get next character after cursor
function! s:NextChar()
  return getline('.')[getpos('.')[2] - 1]
endfunction

" Get the current pair before and after cursor
function! s:CurrentPair()
  return getline('.')[getpos('.')[2] - 2:getpos('.')[2] - 1]
endfunction

" Check if a character is a symmetrical pair
function! s:IsSym(char)
  return has_key(g:Parried, a:char) && a:char == g:Parried[a:char]
endfunction

" Check if cursor is at a pair
function! s:AtPair()
  " Create a regex of all pairs
  let regex = join(values(map(copy(g:Parried), {key, val -> key . val})), '\|')
  " Return whether the current pair is a match
  return s:CurrentPair() =~# regex
endfunction

" Check if cursor is at a asymmetrical pair
function! s:AtAsymPair()
  return s:AtPair() && !s:IsSym(s:PrevChar())
endfunction

" Check if cursor is at a symmetrical pair
function! s:AtSymPair()
  return s:AtPair() && s:IsSym(s:PrevChar())
endfunction

" Check if cursor is within a string
function! s:InString()
  let syngroups = join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'))
  return syngroups =~ 'string'
endfunction

" Check if closing pair should be added
function! s:Parry(char)
  " Never close within a string
  if s:InString()
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
  if s:IsSym(a:char)
    return ((s:PrevChar() !~# '\S') && (s:NextChar() !~# '\S')) ||
         \ ((s:PrevChar() =~# keys) && (s:NextChar() =~# values))
  else
    return (s:NextChar() !~# '\S') || (s:NextChar() =~# values)
  endif
endfunction

" vim:fdl=0:fdm=indent:
