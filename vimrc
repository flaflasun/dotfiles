"-------------------------------------------------------------------------------
" flaflasun's .vimrc
"-------------------------------------------------------------------------------
" Basic: {{{

" Initialize {{{

" Note: Skip initialization for vim-tiny or vim-small.
if 0 | endif

if &compatible
  set nocompatible
endif

let s:is_windows = has('win32') || has('win64')

function! IsWindows() abort
  return s:is_windows
endfunction

if IsWindows()
  if !exists($MYGVIMRC)
    let set shellslash
    let $MYGVIMRC = expand('~/_gvimrc')
  endif

  let $DOTVIM = expand('~/_vim')
else
  if !exists($MYGVIMRC)
    let $MYGVIMRC = expand('~/.gvimrc')
  endif

  let $DOTVIM = expand('~/.vim')
endif

function! s:smart_mkdir(path)
  if !isdirectory(a:path)
    call mkdir(a:path, 'p')
  endif
endfunction

let $SWAP_DIR = $DOTVIM . '/tmp/swap'
call s:smart_mkdir($SWAP_DIR)
let $BACKUP_DIR = $DOTVIM . '/tmp/backup'
call s:smart_mkdir($BACKUP_DIR)
let $UNDO_DIR = $DOTVIM . '/tmp/undo'
call s:smart_mkdir($UNDO_DIR)
let $CACHE_DIR = expand('~/.cache')
call s:smart_mkdir($CACHE_DIR)

" Disable Vi compatible.
if has('vim_starting')
  "set nocompatible
  if IsWindows()
    set runtimepath^=$DOTVIM
  endif
endif

language C

" Set augroup.
augroup MyAutoCmd
  autocmd!
augroup END

" Echo startup time on start
if has('vim_starting') && has('reltime')
  let g:startuptime = reltime()
  augroup StartupTime
    autocmd!
    autocmd VimEnter * let g:startuptime = reltime(g:startuptime) | redraw
    \ | echomsg 'startuptime: ' . reltimestr(g:startuptime)
  augroup END
endif

function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

" }}}

" Encoding {{{

set encoding=utf-8

" setting of terminal encoding.
if !has('gui_running')
  if &term ==# 'win32' || &term ==# 'win64'
    set termencoding=cp932
    set encoding=japan
  else
    if $ENV_ACCESS ==# 'linux'
      set termencoding=euc-jp
    endif
  endif
endif

set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,iso-2022-jp,euc-jp,cp932
set fileformats=unix,dos,mac

if exists('&ambiwidth')
  set ambiwidth=double
endif

scriptencoding utf-8

" }}}

" Function {{{

function! s:smart_close()
  if winnr('$') != 1
    close
  endif
endfunction

function! s:str_width_part(str, width)
  if a:width <= 0
    return ''
  endif
  let ret = a:str
  let width = s:wcs_width(a:str)
  while width > a:width
    let char = matchstr(ret, '.$')
    let ret = ret[: -1 - len(char)]
    let width -= s:wcs_width(char)
  endwhile

  return ret
endfunction

function! s:wcs_width(str)
  return strwidth(a:str)
endfunction

function! s:get_buffer_byte()
  let byte = line2byte(line('$') + 1)
  if byte == -1
    return 0
  else
    return byte - 1
  endif
endfunction

function! s:remove_line_in_last_line()
  if getline('$') == ""
     $delete _
  endif
endfunction

" }}}

" History {{{

set history=10000

" }}}

" Backup {{{

set directory=$SWAP_DIR
set backupdir=$BACKUP_DIR
set undodir=$UNDO_DIR

set undofile

" }}}

" }}}

"-------------------------------------------------------------------------------
" View: {{{

" Colorscheme {{{

if !has('gui_running')
  colorscheme default
endif

" }}}

" Title {{{

set title
set titlelen=95
" Title string.
let &titlestring="
      \ %{expand('%:p:.:~')}%(%m%r%w%)
      \ %<\(%{".s:SID_PREFIX()."str_width_part(
      \ fnamemodify(&filetype ==# 'vimfiler' ?
      \ substitute(b:vimfiler.current_dir, '.\\zs/$', '', '') : getcwd(), ':~'),
      \ &columns-len(expand('%:p:.:~')))}\) - VIM"

" }}}

" Tabline {{{

function! s:make_tabline()  " {{{
  let s = ''

  for i in range(1, tabpagenr('$'))
    let bufnrs = tabpagebuflist(i)
    let bufnr = bufnrs[tabpagewinnr(i) - 1]  " first window, first appears

    let no = i  " display 0-origin tabpagenr.
    let mod = getbufvar(bufnr, '&modified') ? '!' : ' '

    let title = fnamemodify(bufname(bufnr), ':t')
    if empty(title)
      let title = 'NO NAME'
    endif
    let title = '[' . title . ']'

    let s .= '%'.i.'T'
    let s .= '%#' . (i == tabpagenr() ? 'TabLineSel' : 'TabLine') . '#'
    let s .= ' ' . no . ':' . title
    let s .= mod
    let s .= '%#TabLineFill# '
  endfor

  let s .= '%#TabLineFill#%T%=%#TabLine#'
  return s
endfunction "}}}

let &tabline = '%!'. s:SID_PREFIX() . 'make_tabline()'
set showtabline=2

" }}}

" Editor {{{

" Disable bell.
set visualbell
set t_vb=

" Enable syntax color.
syntax enable

set scrolloff=3

" Show line number.
set number

" Show <Tab> and <Space>
set list
set listchars=tab:>-,trail:_,extends:>,precedes:>
" Don't wrap long line.
set nowrap
set linebreak
set breakat=\ \	;:,!?
set showbreak=> 

set nocursorline
set colorcolumn=81

set conceallevel=2 concealcursor=iv

set display=lastline

set lazyredraw

" }}}

" Status-line {{{

set laststatus=2

" Set statusline.
let &statusline="%{winnr('$')>1?'['.winnr().'/'.winnr('$')"
      \ . ".(winnr('#')==winnr()?'#':'').']':''}\ "
      \ . "%{(&previewwindow?'[preview] ':'').expand('%:t:.')}"
      \ . "\ %=%m%y%{'['.(&fenc!=''?&fenc:&enc).','.&ff.']'}"
      \ . "%{printf(' %5d/%d',line('.'),line('$'))}"

" }}}

" Command-line {{{

set cmdheight=2
set showcmd

set shortmess=aTI

" }}}

" Window {{{

set cmdwinheight=5
set noequalalways

set previewheight=10
set helpheight=12

set fillchars=vert:\ 

" }}}

" GUI {{{

set viewdir=~/.vim/view viewoptions-=options viewoptions+=slash,unix
if has('gui_running')
  " Disable menu.vim
  set guioptions=Mc
  " Does not use IM by default.
  set iminsert=0 imsearch=0
endif

" }}}

" }}}

"-------------------------------------------------------------------------------
" Edit: {{{
"

" Movement {{{

" Enable backspace delete indent and newline.
set backspace=indent,eol,start
" Wrap conditions.
set whichwrap+=b,s,h,l,<,>,~,[,]

set nostartofline

" }}}

" Split {{{

set splitbelow
set splitright

" Use vsplit mode
if has('vim_starting') && !has('gui_running') && has('vertsplit')
  function! g:EnableVsplitMode()
    " enable origin mode and left/right margins
    let &t_CS = "y"
    let &t_ti = &t_ti . "\e[?6;69h"
    let &t_te = "\e[?6;69l" . &t_te
    let &t_CV = "\e[%i%p1%d;%p2%ds"
    call writefile([ "\e[?6h\e[?69h" ], "/dev/tty", "a")
  endfunction

  " old vim does not ignore CPR
  map <special> <Esc>[3;9R <Nop>

  " new vim can't handle CPR with direct mapping
  " map <expr> ^[[3;3R g:EnableVsplitMode()
  set t_F9=^[[3;3R
  map <expr> <t_F9> g:EnableVsplitMode()
  let &t_RV .= "\e[?6;69h\e[1;3s\e[3;9H\e[6n\e[0;0s\e[?6;69l"
endif

" }}}

" Search {{{

" Ignore the case of normal letters.
set ignorecase
" Ignore case on insert completion.
set infercase

set smartcase

" Enable incremental search.
set incsearch
" Disable highlight search.
set nohlsearch

" Searches wrap around the end of the file.
set wrapscan

" }}}

" Complement {{{

set nowildmenu
set wildmode=longest,list
set showfulltag

set wildoptions=tagfile

set completeopt=menu

set complete=.

set pumheight=10

" }}}

" Indent {{{

" Enable smart indent.
set autoindent smartindent
" Smart insert tab setting.
set smarttab
" Exchange tab to spaces.
set expandtab
" Substitute <Tab> with blanks.
set tabstop=2
" Spaces instead <Tab>.
set softtabstop=2
" Autoindent width.
set shiftwidth=2
" Round indent by shiftwidth.
set shiftround

" }}}

" Fold {{{

set foldenable
set foldmethod=marker
set foldcolumn=0
set foldlevel=1
set foldnestmax=2
set commentstring=%s

" }}}

" Spelling  {{{

set spelllang=en,cjk
set nospell

" }}}

" Clipboard {{{

" Use clipboard register.
if has('unnamedplus')
  set clipboard& clipboard+=unnamedplus
else
  set clipboard& clipboard+=unnamed
endif

" }}}

" FileType {{{

augroup MyAutoCmd
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufWritePre *.go call s:remove_line_in_last_line()
augroup END

" }}}

" Command {{{

command! -nargs=1 -complete=file Rename f <args> | call delete(expand)

" }}}

" Other {{{

" Highlight parenthesis.
set showmatch

" Highlight when CursorMoved.
set cpoptions-=m
set matchtime=3
set matchpairs+=<:>

set tags=./tags;

set modeline

set diffopt=filler,vertical

set grepprg=grep\ -nH

" Display another buffer when current buffer isn't saved.
set hidden

" Keymapping timeout.
set timeout timeoutlen=3000 ttimeoutlen=100
" CursorHold time.
set updatetime=4000

set report=0

" Auto reload if file is changed.
set autoread

set virtualedit=block

set nrformats=

" Use autofmt.
set formatexpr=autofmt#japanese#formatexpr()

" }}}

" }}}

"-------------------------------------------------------------------------------
" Key Mappings: {{{
"

" Visual mode keymappings {{{

xnoremap <C-j> "zx"zp`[V`]
xnoremap <C-k> "zx<Up>"zP`[V`]

xnoremap <TAB> >
xnoremap <S-TAB> <

xnoremap > >gv
xnoremap < <gv

xnoremap <SID>(command-line-enter) q:

xnoremap ; <NOP>
xmap ;; <SID>(command-line-enter)

xnoremap r <C-v>
xnoremap v $h

" }}}

" Insert mode keymappings {{{

" <C-f>, <C-b>: page move.
inoremap <C-f> <Right>
inoremap <C-b> <Left>
" move to head.
inoremap <silent><C-a> <C-o>g^
" move to end.
inoremap <silent><C-e> <C-o>g$
" delete char.
inoremap <C-d> <Del>

inoremap <C-w> <C-g>u<C-w>
inoremap <C-u> <C-g>u<C-u>

" Completion by <TAB>.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

" Easy Escape.
inoremap jj <ESC>
onoremap jj <ESC>
inoremap j<Space> j
onoremap j<Space> j

" }}}

" Command-line mode keymappings {{{

cnoremap <C-a> <Home>
cnoremap <C-b> <Left>
cnoremap <C-d> <Del>
cnoremap <C-e> <End>
cnoremap <C-f> <Right>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>
cnoremap <C-y> <C-r>*

" }}}

" Command line buffer {{{

nnoremap <SID>(command-line-enter) q:

nnoremap ; <NOP>
nmap ;; <SID>(command-line-enter)

autocmd MyAutoCmd CmdwinEnter * call s:init_cmdwin()
function! s:init_cmdwin()
  nnoremap <buffer> q :<C-u>quit<CR>
endfunction

" }}}

" Normal-mode {{{

nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

nnoremap <C-j> "zdd"zp
nnoremap <C-k> "zdd<Up>"zP

nnoremap > >>
nnoremap < <<

nnoremap <C-]> g<C-]>

nnoremap [Space] <NOP>
nmap <Space> [Space]

nnoremap Y y$
nnoremap <silent> [Space]y "zyiw
nnoremap [Space]s <Space>y:%s/<C-r>z//g<Left><Left>
nnoremap x "_x

nnoremap <silent> [Space]ev :<C-u>edit $MYVIMRC<CR>
nnoremap <silent> [Space]eg :<C-u>edit $MYGVIMRC<CR>
nnoremap <silent> [Space]rv
      \ :<C-u>source $MYVIMRC \|
      \ echo "source $MYVIMRC"<CR>
nnoremap <silent> [Space]rg
      \ :<C-u>source $MYGVIMRC \|
      \ echo "source $MYGVIMRC"<CR>

noremap [Space]j zj
noremap [Space]k zk
noremap [Space]h zc
noremap [Space]l zo

nnoremap <silent> [Space]t2 :<C-u>setl shiftwidth=2 softtabstop=2<CR>
nnoremap <silent> [Space]t4 :<C-u>setl shiftwidth=4 softtabstop=4<CR>
nnoremap <silent> [Space]t8 :<C-u>setl shiftwidth=8 softtabstop=8<CR>

nnoremap <silent> [Space]o :<C-u>call append(line('.'), '')<Cr>j
nnoremap <silent> [Space]O :<C-u>call append(line('.') - 1, '')<Cr>k

nnoremap [s] <NOP>
nmap s [s]

nnoremap <silent> [s]s :<C-u>split<CR>
nnoremap <silent> [s]v :<C-u>vsplit<CR>

nnoremap [s]h <C-w>h
nnoremap [s]j <C-w>j
nnoremap [s]k <C-w>k
nnoremap [s]l <C-w>l

nnoremap [s]H <C-w>H
nnoremap [s]J <C-w>J
nnoremap [s]K <C-w>K
nnoremap [s]L <C-w>L
nnoremap [s]r <C-w>r

nnoremap [s]= <C-w>=
nnoremap [s]> <C-w>>
nnoremap [s]< <C-w><
nnoremap [s]+ <C-w>+
nnoremap [s]- <C-w>-

nnoremap [s]n gt
nnoremap [s]p gT

nnoremap <silent> [s]c :<C-u>tabnew<CR>
nnoremap <silent> [s]q :<C-u>q<CR>
nnoremap <silent> [s]Q :<C-u>bd<CR>

let g:mapleader = ','
let g:maplocalleader = 'm'
nnoremap , <NOP>
nnoremap m <NOP>

nnoremap ; <NOP>
nmap ;; <SID>(command-line-enter)

nnoremap <silent> <Leader><Leader> :<C-u>update<CR>

" }}}

" Help {{{

" Set <S-k> help.
set keywordprg=:help

augroup MyAutoCmd
  autocmd FileType help
        \ nnoremap <buffer><silent> q :<C-u>call <sid>smart_close()<CR>
augroup END

" }}}

" Don't use commands {{{

nnoremap ZZ <NOP>
nnoremap ZQ <NOP>
nnoremap Q <NOP>

" }}}

" }}}

"-------------------------------------------------------------------------------
" Plugins: {{{

" Disable plugins {{{

" Disable GetLatestVimPlugin.vim
let g:loaded_getscriptPlugin = 1

" }}}

" Setup {{{

let $DEIN_DIR = $CACHE_DIR . '/dein'
let $DEIN_REPO_DIR = $DEIN_DIR . '/repos/github.com/Shougo/dein.vim'
let $VIMRC_DIR = $DOTVIM . '/rc'
let $DEINTOML = $VIMRC_DIR . '/dein.toml'
let $DEINLAZYTOML = $VIMRC_DIR . '/deinlazy.toml'

if &runtimepath !~# '/dein.vim'
  if !isdirectory($DEIN_REPO_DIR)
    execute '!git clone https://github.com/Shougo/dein.vim' $DEIN_REPO_DIR
  endif
  execute 'set runtimepath^=' . fnamemodify($DEIN_REPO_DIR, ':p')
endif

if dein#load_state($DEIN_DIR)
  call dein#begin($DEIN_DIR, [$DEINTOML, $DEINLAZYTOML])
  let $VIMRC_DIR = $DOTVIM . '/rc'

  call dein#load_toml($DEINTOML, {'lazy': 0})
  call dein#load_toml($DEINLAZYTOML, {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

" Installation check.
if dein#check_install()
  call dein#install()
endif

filetype plugin indent on

" }}}

" }}}

"-------------------------------------------------------------------------------
" Others: {{{

" Format {{{

augroup MyFormatOptions
  autocmd!
  autocmd FileType * setlocal formatoptions-=ro
augroup END

" }}}

set mouse=a

set helplang& helplang=ja,en

set secure

" }}}
