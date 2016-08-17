"-------------------------------------------------------------------------------
" My .gvimrc
"-------------------------------------------------------------------------------
" Fonts: {{{

" Sample text:
"   ABCDEFGHIJKLMOPQRSTUVWXYZ
"   abcdefghijklmopqrstuvwxyz
"   1234567890
"   あいうえお かきくけこ さしすせそ たちつてと なにぬねの
"   はひふへほ まみむめも や　ゆ　よ らりるれろ わ　を　ん
"   アイウエオ カキクケコ サシスセソ タチツテト ナニヌネノ
"   ハヒフヘホ マミムメモ ヤ　ユ　ヨ ラリルレロ ワ　ヲ　ン
"   祇辻飴葛蛸鯖鰯噌庖箸

" Number of pixel lines inserted between characters.
set linespace=2

if has('win32') || has('win64')
  " For Windows.
  set guifontwide=Ricty\ Diminished\ Regular:h14
  set guifont=Ricty\ Diminished\ Regular:h14

  if has('kaoriya')
    " For Kaoriya only.
    set ambiwidth=auto
  endif
elseif has('mac')
  " For Mac.
  set guifontwide=Ricty\ Diminished\ Regular\ Plus\ Nerd\ File\ Types:h16
  set guifont=Ricty\ Diminished\ Regular\ Plus\ Nerd\ File\ Types:h16
else
  " For Linux.
  set guifontwide=Ricty\ Diminished\ Regular\ Plus\ Nerd\ File\ Types:h16
  set guifont=Ricty\ Diminished\ Regular\ Plus\ Nerd\ File\ Types:h16
endif

" }}}

"-------------------------------------------------------------------------------
" Window: {{{

if has('win32') || has('win64')
  " Width of window.
  set columns=230
  " Height of window.
  set lines=55

  " Set transparency.
  "autocmd GuiEnter * set transparency=221
  " Toggle font setting.
  command! TransparencyToggle let &transparency =
        \ (&transparency != 255 && &transparency != 0)? 255 : 220
  nnoremap TT     :<C-u>TransparencyToggle<CR>
else
  " Width of window.
  set columns=150
  " Height of window.
  set lines=40
endif

" Save the setting of window.
let g:save_window_file = expand('~/.vimwinpos')
augroup SaveWindow
  autocmd!
  autocmd VimLeavePre * call s:save_window()
  function! s:save_window()
    let options = [
          \ 'set columns=' . &columns,
          \ 'set lines=' . &lines,
          \ 'winpos ' . getwinposx() . ' ' . getwinposy(),
          \ ]
    call writefile(options, g:save_window_file)
  endfunction
augroup END

if filereadable(g:save_window_file)
  execute 'source' g:save_window_file
endif

" }}}

"-------------------------------------------------------------------------------
" Mouse: {{{

set mousemodel=extend

" Don't focus the window when the mouse pointer is moved.
set nomousefocus
" Hide mouse pointer on insert mode.
set mousehide

" Paste.
nnoremap <RightMouse> "+p
xnoremap <RightMouse> "+p
nnoremap <RightMouse> <C-r><C-o>+
cnoremap <RightMouse> <C-r>+

" }}}

"-------------------------------------------------------------------------------
" Menu: {{{


" Hide toolbar and menus.
set guioptions-=Tt
set guioptions-=m
" Scrollbar is always off.
set guioptions-=rL
" Not guitablabel.
set guioptions-=e
" Confirm without window.
set guioptions+=c

" }}}

"-------------------------------------------------------------------------------
" Views: {{{

" Don't flick cursor.
set guicursor&
set guicursor+=a:blinkon0

" Disable bell.
set novisualbell
set visualbell t_vb=

set cursorline


if neobundle#tap('vim-nightowl') " {{{
  colorscheme nightowl
else
  colorscheme evening
endif " }}}

hi clear CursorLine

" }}}

"-------------------------------------------------------------------------------
" Others: {{{


" }}}
