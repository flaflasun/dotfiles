"-------------------------------------------------------------------------------
" flaflasun's .vimrc
"-------------------------------------------------------------------------------
" Basic: {{{

" Note: Skip initialization for vim-tiny or vim-small.
if 0 | endif

" Valiable {{{

let s:is_windows = has('win16') || has('win32') || has('win64')

if !exists($MYGVIMRC)
  let $MYGVIMRC = expand('~/.gvimrc')
endif

let $DOTVIM = expand('~/.vim')

let $VIM_BUNDLE = $DOTVIM . '/bundle'
let $NEOBUNDLE_PATH = $VIM_BUNDLE . '/neobundle.vim'

let $SWAP_DIR = $DOTVIM . '/tmp/swap'
let $BACKUP_DIR = $DOTVIM . '/tmp/backup'
let $UNDO_DIR = $DOTVIM . '/tmp/undo'

" }}}

" Initialize {{{

" Disable Vi compatible.
if has('vim_starting')
  "set nocompatible
  if has(s:is_windows)
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
  augroup MyAutoCmd
    autocmd! VimEnter * let g:startuptime = reltime(g:startuptime) | redraw
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
set novisualbell
set visualbell t_vb=

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

" Parenthesis {{{

" Highlight parenthesis.
set showmatch
" Highlight when CursorMoved.
set cpoptions-=m
set matchtime=3
set matchpairs+=<:>

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

" Complete {{{

set wildmenu
set wildmode=longest:full,full
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

" Tags {{{

set tags=./tags;

" }}}

" Modeline {{{

set modeline

" }}}

" Diff {{{

set diffopt=filler,vertical

" }}}

" Buffer {{{

" Display another buffer when current buffer isn't saved.
set hidden

" }}}

" Grep {{{

set grepprg=grep\ -nH

" }}}

" Time-out {{{

" Keymapping timeout.
set timeout timeoutlen=3000 ttimeoutlen=100

" CursorHold time.
set updatetime=4000

" }}}

" FileType {{{

augroup MyAutoCmd
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufWritePre *.go call s:remove_line_in_last_line()
augroup END

" }}}

" Other {{{

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

xnoremap <TAB> >
xnoremap <S-TAB> <

xnoremap > >gv
xnoremap < <gv

xnoremap <SID>(command-line-enter) q:

xnoremap ; <NOP>
xmap ;; <SID>(command-line-enter)

xnoremap r <C-v>
xnoremap v $h

xnoremap [Space] <NOP>
xmap <Space> [Space]

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

nnoremap Y y$

nnoremap <C-j> <C-e>gj
nnoremap <C-k> <C-y>gk

nnoremap > >>
nnoremap < <<

nnoremap <C-]> g<C-]>

nnoremap [Space] <NOP>
nmap <Space> [Space]

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

if has('vim_starting')
  if &compatible
    set nocompatible
  endif
  set runtimepath+=$NEOBUNDLE_PATH
endif

" }}}

" List {{{

call neobundle#begin(expand($VIM_BUNDLE))

if neobundle#load_cache() " {{{
  NeoBundleFetch 'Shougo/neobundle.vim'

  NeoBundle 'Shougo/vimproc.vim', {
        \ 'build' : {
        \   'windows' : 'tools\\update-dll-mingw',
        \   'cygwin' : 'make -f make_cygwin.mak',
        \   'mac' : 'make',
        \   'linux' : 'make',
        \   'unix' : 'gmake',
        \ }}

  " UI {{{

  NeoBundleLazy 'Shougo/vimshell.vim', { 'depends' : [ 'Shougo/vimproc.vim' ] }
  call neobundle#config('vimshell.vim', {
        \   'autoload' : {
        \     'commands' : [ 'VimShell', 'VimShellPop', 'VimShellTab' ]
        \   }
        \ })

  NeoBundle 'justinmk/vim-dirvish'

  NeoBundleLazy 'majutsushi/tagbar'
  call neobundle#config('tagbar', {
        \   'autoload' : {
        \     'commands' : [ 'TagbarToggle' ]
        \   }
        \ })

  " Unite
  NeoBundle 'Shougo/unite.vim'
  NeoBundle 'Shougo/unite-help', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'Shougo/unite-outline', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'Shougo/unite-session', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'thinca/vim-unite-history', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'tsukkee/unite-tag', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'ujihisa/unite-colorscheme', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'ujihisa/unite-font', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'osyo-manga/unite-highlight', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'pasela/unite-webcolorname', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'Shougo/neomru.vim', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'Shougo/neossh.vim', { 'depends' : [ 'Shougo/unite.vim', 'Shougo/vimproc.vim' ] }
  NeoBundle 'thinca/vim-ref', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'glidenote/memolist.vim', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'kmnk/vim-unite-giti', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'sorah/unite-ghq', { 'depends' : [ 'Shougo/unite.vim' ] }

  " }}}

  " Completion {{{

  NeoBundleLazy 'Shougo/neocomplete.vim'
  call neobundle#config('neocomplete.vim', {
        \   'autoload' : {
        \     'insert' : 1,
        \   }
        \ })

  NeoBundleLazy 'thinca/vim-ambicmd'
  call neobundle#config('vim-ambicmd', {
        \   'autoload' : {
        \     'insert' : 1,
        \   }
        \ })


  " Snippet
  NeoBundleLazy 'Shougo/neosnippet.vim'
  call neobundle#config('neosnippet.vim', {
        \   'autoload' : {
        \     'insert' : 1,
        \     'filetype' : 'snippet',
        \     'commands' : [ 'NeoSnippetEdit', 'NeoSnippetSource' ],
        \     'filetypes' : [ 'nsnippet' ],
        \     'unite_sources' :
        \       ['snippet', 'neosnippet/user', 'neosnippet/runtime']
        \   }
        \ })

  NeoBundle 'Shougo/neosnippet-snippets', { 'depends' : 'Shougo/neosnippet.vim' }
  NeoBundle 'honza/vim-snippets', { 'depends' : 'Shougo/neosnippet.vim' }

  " }}}

  " Text object {{{

  NeoBundle 'kana/vim-textobj-user'
  NeoBundle 'kana/vim-textobj-entire', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'kana/vim-textobj-line', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'kana/vim-textobj-lastpat', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'kana/vim-textobj-fold', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'kana/vim-textobj-function', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'kana/vim-textobj-indent', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'mattn/vim-textobj-url', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'rhysd/vim-textobj-ruby', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'osyo-manga/vim-textobj-multiblock', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'osyo-manga/vim-textobj-multitextobj', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'osyo-manga/vim-textobj-blockwise', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'thinca/vim-textobj-between', { 'depends' : 'kana/vim-textobj-user' }

  " }}}

  " Language {{{

  " Git {{{

  NeoBundle 'tpope/vim-fugitive'
  NeoBundleLazy 'cohama/agit.vim'
  call neobundle#config('agit.vim', {
        \   'autoload' : {
        \     'commands' : [ 'Agit', 'AgitFile' ],
        \   }
        \ })

  " Gist
  NeoBundleLazy 'mattn/gist-vim', { 'depends' : [ 'mattn/webapi-vim' ] }
  call neobundle#config('gist-vim', {
        \   'autoload' : {
        \     'commands' : [ 'Gist' ],
        \   }
        \ })

  "}}}

  " Ruby {{{

  NeoBundleLazy 'vim-ruby/vim-ruby'
  call neobundle#config('vim-ruby', {
        \   'autoload' : {
        \     'filetypes' : 'ruby'
        \   }
        \ })

  NeoBundleLazy 'yuku-t/vim-ref-ri', { 'depends' : [ 'Shougo/unite.vim', 'thinca/vim-ref' ] }
  call neobundle#config('vim-ref-ri', {
        \   'autoload' : {
        \     'filetypes' : 'ruby'
        \   }
        \ })

  NeoBundleLazy 't9md/vim-ruby-xmpfilter'
  call neobundle#config('vim-ruby-xmpfilter', {
        \   'autoload' : {
        \     'filetypes' : 'ruby'
        \   }
        \ })

  NeoBundleLazy 'tpope/vim-endwise'
  call neobundle#config('vim-endwise', {
        \   'autoload' : {
        \     'filetypes' : 'ruby'
        \   }
        \ })

  NeoBundleLazy 'scrooloose/syntastic'
  call neobundle#config('syntastic', {
        \ 'autoload' : {
        \     'filetypes' : 'ruby'
        \   }
        \ })


  " Ruby on Rails
  NeoBundleLazy 'tpope/vim-rails'
  call neobundle#config('vim-rails', {
        \   'autoload' : {
        \     'filetypes' : ['haml', 'ruby', 'eruby']
        \   }
        \ })

  NeoBundleLazy 'basyura/unite-rails', { 'depends' : [ 'Shougo/unite.vim' ] }
  call neobundle#config('unite-rails', {
        \   'autoload' : {
        \     'filetypes' : ['haml', 'ruby', 'eruby']
        \   }
        \ })

  "}}}

  " Golang {{{

  NeoBundleLazy 'fatih/vim-go'
  call neobundle#config('vim-go', {
        \   'autoload' : {
        \     'filetypes' : 'go'
        \   }
        \ })

  NeoBundleLazy 't9md/vim-transform'
  call neobundle#config('vim-transform', {
        \   'autoload' : {
        \     'filetypes' : 'go'
        \   }
        \ })

  " }}}

  " Swift {{{

  NeoBundleLazy 'toyamarinyon/vim-swift'
  call neobundle#config('vim-swift', {
        \   'autoload' : {
        \     'filetypes' : [ 'swift']
        \   }
        \ })

  " }}}

  " Web {{{

  " HTML
  NeoBundleLazy 'mattn/emmet-vim'
  call neobundle#config('emmet-vim', {
        \   'autoload' : {
        \     'filetypes' : [ 'html', 'css']
        \   }
        \ })

  " Markdown
  NeoBundle 'godlygeek/tabular'
  NeoBundleLazy 'plasticboy/vim-markdown'
  call neobundle#config('vim-markdown', {
        \   'autoload' : {
        \     'filetypes' : [ 'markdown']
        \   }
        \ })

  NeoBundleLazy 'mattn/vim-maketable'
  call neobundle#config('vim-maketable', {
        \   'autoload' : {
        \     'filetypes' : [ 'markdown']
        \   }
        \ })

  " Javascript
  NeoBundleLazy 'jelera/vim-javascript-syntax'
  call neobundle#config('vim-javascript-syntax', {
        \   'autoload' : {
        \     'filetypes' : 'javascript'
        \   }
        \ })

  " CoffeeScript
  NeoBundleLazy 'kchmck/vim-coffee-script'
  call neobundle#config('vim-coffee-script', {
        \   'autoload' : {
        \     'filetypes' : 'coffee'
        \   }
        \ })

  " SASS
  NeoBundleLazy 'AtsushiM/search-parent.vim'
  call neobundle#config('search-parent.vim', {
          \   'autoload' : {
          \     'filetypes' : [ 'sass', 'scss']
          \   }
          \ })

  NeoBundleLazy 'AtsushiM/sass-compile.vim', { 'depends': 'AtsushiM/search-parent.vim' }
  call neobundle#config('sass-compile.vim', {
          \   'autoload' : {
          \     'filetypes' : [ 'sass', 'scss']
          \   }
          \ })

  " }}}

  " Ansible
  NeoBundleLazy 'chase/vim-ansible-yaml'
  call neobundle#config('vim-ansible-yaml', {
        \   'autoload' : {
        \     'filetypes' : 'yml'
        \   }
        \ })

  " json
  NeoBundleLazy 'elzr/vim-json'
  call neobundle#config('vim-json', {
        \   'autoload' : {
        \     'filetypes' : 'json'
        \   }
        \ })

  " }}}

  " Auxiliary {{{

  NeoBundleLazy 'tpope/vim-commentary'
  call neobundle#config('vim-commentary', {
        \   'autoload' : {
        \     'commands' : [ 'Commentary' ],
        \   }
        \ })

  NeoBundle 'tpope/vim-surround'
  NeoBundle 'tpope/vim-repeat'
  NeoBundleLazy 'AndrewRadev/switch.vim'
  call neobundle#config('switch.vim', {
        \   'autoload' : {
        \     'commands' : [ 'Switch' ]
        \   }
        \ })

  NeoBundleLazy 'cohama/lexima.vim'
  call neobundle#config('lexima.vim', {
        \   'autoload' : {
        \     'insert' : 1,
        \   }
        \ })

  NeoBundleLazy 'junegunn/vim-easy-align'
  call neobundle#config('vim-easy-align', {
        \   'autoload' : {
        \     'commands' : [ 'EasyAlign' ]
        \   }
        \ })

  NeoBundle 'kana/vim-submode'
  NeoBundle 'thinca/vim-quickrun'

  " Templete
  NeoBundle 'mattn/sonictemplate-vim'

  " }}}

  " Search {{{

  NeoBundle 'haya14busa/incsearch.vim'
  NeoBundle 'haya14busa/incsearch-fuzzy.vim', { 'depends' : [ 'incsearch.vim' ] }
  NeoBundle 'haya14busa/incsearch-migemo.vim', { 'depends' : [ 'incsearch.vim' ] }
  NeoBundle 'haya14busa/vim-asterisk'
  NeoBundle 'haya14busa/vim-migemo'
  NeoBundle 'rhysd/clever-f.vim'
  NeoBundle 'osyo-manga/vim-anzu'
  NeoBundle 'easymotion/vim-easymotion'

  " }}}

  " View {{{

  NeoBundle 'lilydjwg/colorizer'
  NeoBundle 'Yggdroot/indentLine'
  NeoBundle 'LeafCage/foldCC'

  " Colorscheme
  NeoBundle 'tomasr/molokai'
  NeoBundle 'altercation/vim-colors-solarized'
  NeoBundle 'w0ng/vim-hybrid'

  " }}}

  " Others {{{

  NeoBundle 'mattn/webapi-vim'
  NeoBundleLazy 'mattn/excitetranslate-vim', { 'depends': 'mattn/webapi-vim' }
  call neobundle#config('excitetranslate-vim', {
        \ 'autoload' : {
        \   'commands': ['ExciteTranslate']
        \   }
        \ })

  NeoBundle 'tyru/open-browser.vim'
  NeoBundle 'tyru/open-browser-github.vim'
  NeoBundleLazy 'kannokanno/previm'
  call neobundle#config('previm', {
        \ 'autoload' : {
        \   'commands': ['PrevimOpen']
        \   }
        \ })

  NeoBundle 'rizzatti/dash.vim'
  NeoBundle 'mattn/benchvimrc-vim'
  NeoBundle 'kana/vim-niceblock'
  NeoBundle 'airblade/vim-rooter'

  " Document
  NeoBundle 'vim-jp/vimdoc-ja'

  " }}}

  NeoBundleSaveCache
endif "}}}

  " My Plugin {{{

  call neobundle#local('~/Dropbox/work/dev/vim',
        \ {}, ['vim-nightowl'])

 "}}}

call neobundle#end()

filetype plugin indent on

if !has('vim_starting')
  " Installation check.
  NeoBundleCheck
endif

" }}}

" Configurations  {{{

" UI {{{

if neobundle#tap('vimshell.vim') " {{{

  let g:vimshell_max_command_history = 0
  let g:vimshell_prompt = 'vimshell % '
  let g:vimshell_secondary_prompt = '> '
  let g:vimshell_user_prompt = '$USER ."@" .hostname() ." [" .getcwd() ."]"'
  let g:vimshell_popup_height = 20

  nnoremap ;vp  :<C-u>VimShellPop -toggle<CR>
  nnoremap ;vb  :<C-u>VimShellBufferDir<CR>
  nnoremap ;vd  :<C-u>VimShellCurrentDir<CR>
  nnoremap ;vv  :<C-u>VimShell<CR>

  call neobundle#untap()
endif " }}}

if neobundle#tap('vim-dirvish') " {{{

  map <silent> ;e :<C-u>Dirvish<CR>

  augroup MyDirvish
    autocmd!
    " Map t to "open in new tab".
    autocmd FileType dirvish nnoremap <buffer> t
        \ :tabnew <C-R>=fnameescape(getline('.'))<CR><CR>

    " Map CTRL-R to reload the Dirvish buffer.
    autocmd FileType dirvish nnoremap <buffer> <C-R> :<C-U>Dirvish %<CR>

    " Map gh to hide "hidden" files.
    autocmd FileType dirvish nnoremap <buffer> gh 
        \ :set ma<bar>g@\v/\.[^\/]+/?$@d<cr>:set noma<cr>

    " Map h to Open the parent directory.
    autocmd FileType dirvish nnoremap <buffer><silent> h :Dirvish %:h:h<CR>

    " Map ~ to Open the home directory.
    autocmd FileType dirvish nnoremap <buffer><silent> ~ :Dirvish ~<CR>
  augroup END


  call neobundle#untap()
endif " }}}

if neobundle#tap('tagbar') " {{{

  nnoremap ;t :<C-u>TagbarToggle<CR>

  call neobundle#untap()
endif " }}}

if neobundle#tap('unite.vim') " {{{

  " Plugin key-mappings.
  nnoremap [unite] <NOP>
  xnoremap [unite] <NOP>
  nmap ;u [unite]
  xmap ;u [unite]

  nnoremap [unite]u :Unite<Space>
  nnoremap <silent> ;b :<C-u>Unite -buffer-name=bookmark bookmark<CR>
  nnoremap <silent> ;d :<C-u>Unite -start-insert directory_rec/async:<cr>
  nnoremap <silent> ;f :<C-u>Unite -start-insert file_rec/async:<cr>

  nnoremap <silent> [unite]b :<C-u>Unite -buffer-name=buffer buffer<CR>
  nnoremap <silent> [unite]c
        \:<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>
  nnoremap <silent> [unite]g :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
  nnoremap <silent> [unite]h :<C-u>Unite -buffer-name=help help -start-insert<CR>
  nnoremap <silent> [unite]j :<C-u>Unite -buffer-name=jump jump<CR>
  nnoremap <silent> [unite]k :<C-u>Unite -buffer-name=change change jump<CR>
  nnoremap <silent> [unite]/
        \ :<C-u>Unite -buffer-name=search -start-insert line<CR>
  nnoremap <silent> [unite]m :<C-u>Unite -buffer-name=mapping mapping<CR>
  nnoremap <silent> [unite]o
        \ :<C-u>Unite -buffer-name=outline outline -start-insert<CR>
  nnoremap <silent> [unite]r
        \ :<C-u>Unite -buffer-name=register register history/yank<CR>
  nnoremap <silent> [unite]s :<C-u>Unite session<CR>
  nnoremap <silent> [unite]t :<C-u>Unite -buffer-name=tag tag<CR>

  call unite#custom#source('file_rec/async', 'ignore_pattern',
        \ '\(png\|gif\|jpeg\|jpg\|mp3\|mov\|wav\|avi\|mpg\)$')

  if !exists('g:unite_source_menu_menus')
    let g:unite_source_menu_menus = {}
  endif

  " replace grep with ag.
  if executable('ag')
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
    let g:unite_source_grep_recursive_opt = ''
  endif

  if neobundle#tap('unite-session.vim') " {{{

    let g:unite_source_session_enable_auto_save = 1

    call neobundle#untap()
  endif " }}}

  if neobundle#tap('unite-rails.vim') " {{{

    nnoremap <silent> [unite]rv :<C-U>Unite rails/view<CR>
    nnoremap <silent> [unite]rm :<C-U>Unite rails/model<CR>
    nnoremap <silent> [unite]rc :<C-U>Unite rails/controller<CR>

    call neobundle#untap()
  endif " }}}

  if neobundle#tap('neomru.vim') " {{{

    let g:neomru#time_format = '[%Y/%m/%d %H:%M:%S] '
    let g:neomru#file_mru_limit = 500
    let g:neomru#directory_mru_limit = 100

    nnoremap [unite]f :<C-u>Unite file_mru<CR>
    nnoremap [unite]d :<C-u>Unite directory_mru<CR>

    call neobundle#untap()
  endif " }}}

  if neobundle#tap('vim-ref') " {{{

    let g:ref_use_vimproc=1
    let g:ref_refe_version=2
    let g:ref_refe_encoding = 'utf-8'

    augroup MyAutoCmd
      autocmd FileType ruby nnoremap <silent><buffer> ;k :<C-u>Unite -start-insert -default-action=split ref/refe<CR>
      autocmd FileType python nnoremap <silent><buffer> ;k :<C-u>Unite -start-insert -default-action=split ref/pydoc<CR>
    augroup END

    call neobundle#untap()
  endif " }}}

  if neobundle#tap('memolist.vim') " {{{

    let g:memolist_path = '~/Dropbox/Memo'
    let g:memolist_memo_suffix = 'md'
    let g:memolist_template_dir_path = $DOTVIM . '/template/memolist'
    let g:memolist_unite = 1
    let g:memolist_unite_source = 'file_rec'
    let g:memolist_unite_option = '-start-insert'
    let g:memolist_filename_prefix_none = 1
    let g:memolist_prompt_tags = 1
    let g:memolist_memo_date = "%Y-%m-%d"

    nnoremap [memo] <NOP>
    nmap ;m [memo]
    nnoremap [memo]n :<C-u>MemoNew<CR>
    nnoremap [memo]l :<C-u>MemoList<CR>
    nnoremap [memo]g :<C-u>MemoGrep<CR>

    call neobundle#untap()
  endif " }}}

  if neobundle#tap('unite-ghq') " {{{

    nnoremap <silent> ;g :<C-u>Unite ghq<cr>
    call neobundle#untap()
  endif " }}}

  " Create Vim start page. {{{

  command! UniteStartup
        \ Unite
        \ session file_mru
        \ -no-split
        \ -start-insert

  if has('vim_starting')
    if @% ==# '' && s:get_buffer_byte() == 0
      augroup MyAutoCmd
        autocmd VimEnter * UniteStartup
      augroup END
    endif
  endif

  " }}}

  call neobundle#untap()
endif " }}}

" }}}

" Completion {{{

if neobundle#tap('neocomplete.vim') " {{{

  let g:acp_enableAtStartup = 0
  let g:neocomplete#enable_at_startup = 1

  let g:neocomplete#enable_ignore_case = 1
  let g:neocomplete#enable_smart_case = 1

  " Set minimum syntax keyword length.
  let g:neocomplete#min_keyword_length = 3
  let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

  " Define dictionary.
  let g:neocomplete#sources#dictionary#dictionaries = {
        \ 'default' : '',
        \ 'vimshell' : $HOME.'/.vimshell_hist',
        \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

  " Define keyword.
  if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
  endif
  let g:neocomplete#keyword_patterns['default'] = '\h\w*'

  if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
  endif
  let g:neocomplete#force_omni_input_patterns.go = '[^.[:digit:] *\t]\.\w*'

  " Plugin key-mappings.
  inoremap <expr><C-g>  neocomplete#undo_completion()
  inoremap <expr><C-l>  neocomplete#complete_common_string()

  " Recommended key-mappings.
  " <CR>: close popup and save indent.
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
    return neocomplete#close_popup() . "\<CR>"
    " For no inserting <CR> key.
    "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
  endfunction
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  inoremap <expr><C-h>  neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS>   neocomplete#smart_close_popup()."\<C-h>"

  " Enable omni completion.
  augroup MyAutoCmd
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd FileType go setlocal omnifunc=gocomplete#Complete
  augroup END

  call neobundle#untap()
endif " }}}

if neobundle#tap('vim-ambicmd') " {{{

  cnoremap <expr> <Space> ambicmd#expand("\<Space>")
  cnoremap <expr> <CR>    ambicmd#expand("\<CR>")

  call neobundle#untap()
endif " }}}

" Snippet
if neobundle#tap('neosnippet.vim') " {{{

  " Plugin key-mappings.
  imap <C-k>     <Plug>(neosnippet_expand_or_jump)
  smap <C-k>     <Plug>(neosnippet_expand_or_jump)
  xmap <C-k>     <Plug>(neosnippet_expand_target)

  " SuperTab like snippets behavior.
  imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)"
  \: pumvisible() ? "\<C-n>" : "\<TAB>"
  smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)"
  \: "\<TAB>"

  " For snippet_complete marker.
  if has('conceal')
    set conceallevel=2 concealcursor=i
  endif

  " Enable snipMate compatibility feature.
  let g:neosnippet#enable_snipmate_compatibility = 1

  " Tell Neosnippet about the other snippets
  let g:neosnippet#snippets_directory = $DOTVIM . '/snippets'

  call neobundle#untap()
endif " }}}

if neobundle#tap('neosnippet-snippets') " {{{

  call neobundle#untap()
endif " }}}

if neobundle#tap('vim-snippets') " {{{

  let g:neosnippet#snippets_directory = $DOTVIM . '/snippets' . ',' . $VIM_BUNDLE . '/vim-snippts/snippets'

  call neobundle#untap()
endif " }}}

" }}}

" Language {{{

" Git {{{

if neobundle#tap('vim-fugitive') " {{{

  nnoremap <silent> ;gb :Gblame<CR>
  nnoremap <silent> ;gd :Gdiff<CR>
  nnoremap <silent> ;gs :Gstatus<CR>

  let &statusline="%{winnr('$')>1?'['.winnr().'/'.winnr('$')"
        \ . ".(winnr('#')==winnr()?'#':'').']':''}\ "
        \ . "%{(&previewwindow?'[preview] ':'').expand('%:t:.')}"
        \ . "\ %=%m%y%{'['.(&fenc!=''?&fenc:&enc).','.&ff.']'}"
        \ . "%{fugitive#statusline()}"
        \ . "%{printf(' %5d/%d',line('.'),line('$'))}"

  call neobundle#untap()
endif " }}}

if neobundle#tap('agit.vim') " {{{

  nnoremap <silent> ;ag :Agit<CR>

  let agit_action = {}
  function! agit_action.func(dir)
    if isdirectory(a:dir.word)
      let dir = fnamemodify(a:dir.word, ':p')
    else
      let dir = fnamemodify(a:dir.word, ':p:h')
    endif
    execute 'Agit --dir=' . dir
  endfunction
  call unite#custom#action('file,cdable', 'agit', agit_action)

  let agit_file = { 'description' : 'open the file''s history in agit.vim' }
  function! agit_file.func(candidate)
      execute 'AgitFile' '--file='.a:candidate.action__path
  endfunction
  call unite#custom#action('file', 'agit-file', agit_file)

  call neobundle#untap()
endif " }}}

if neobundle#tap('gist-vim') " {{{

  if has(s:is_windows)
  elseif has('mac')
    let g:gist_clip_command = 'pbcopy'
  else
    let g:gist_clip_command = 'xclip -selection clipboard'
  endif

  let g:gist_detect_filetype = 1

  call neobundle#untap()
endif " }}}

" }}}

" Ruby {{{

if neobundle#tap('vim-ruby-xmpfilter') " {{{

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:xmpfilter_cmd = 'seeing_is_believing'
    augroup MyAutoCmd
      autocmd FileType ruby nmap <buffer> <C-s>m <Plug>(seeing_is_believing-mark)
      autocmd FileType ruby xmap <buffer> <C-s>m <Plug>(seeing_is_believing-mark)
      autocmd FileType ruby imap <buffer> <C-s>m <Plug>(seeing_is_believing-mark)
      autocmd FileType ruby nmap <buffer> <C-s>c <Plug>(seeing_is_believing-clean)
      autocmd FileType ruby xmap <buffer> <C-s>c <Plug>(seeing_is_believing-clean)
      autocmd FileType ruby imap <buffer> <C-s>c <Plug>(seeing_is_believing-clean)
      autocmd FileType ruby nmap <buffer> <C-s>r <Plug>(seeing_is_believing-run_-x)
      autocmd FileType ruby xmap <buffer> <C-s>r <Plug>(seeing_is_believing-run_-x)
      autocmd FileType ruby imap <buffer> <C-s>r <Plug>(seeing_is_believing-run_-x)
  augroup END
  endfunction

  call neobundle#untap()
endif " }}}

if neobundle#tap('syntastic') " {{{

  let g:syntastic_mode_map = { 'mode': 'passive',
        \ 'active_filetypes': ['ruby'] }
  let g:syntastic_ruby_checkers = ['rubocop']

  call neobundle#untap()
endif " }}}

" }}}

" Golang {{{

if neobundle#tap('vim-go') " {{{

  let g:go_fmt_command = "goimports"
  let g:go_fmt_fail_silently = 1
  let g:go_fmt_autosave = 1
  let g:go_snippet_engine = ""
  let g:go_highlight_functions = 1
  let g:go_highlight_methods = 1
  let g:go_highlight_structs = 1
  let g:go_highlight_operators = 1
  let g:go_highlight_build_constraints = 1

  let g:gocomplete#system_function = 'vimproc#system'

  augroup MyAutoCmd
    autocmd FileType Godoc
          \ nnoremap <buffer><silent> q :<C-u>call <sid>smart_close()<CR>
  augroup END

  call neobundle#untap()
endif " }}}

if neobundle#tap('vim-transform') " {{{

  nmap <C-e> <Plug>(transform)
  xmap <C-e> <Plug>(transform)

  call neobundle#untap()
endif " }}}

" }}}

" Web {{{

" HTML
if neobundle#tap('emmet-vim') " {{{

  let g:user_emmet_leader_key='<C-y>'

  call neobundle#untap()
endif " }}}

" Markdown
if neobundle#tap('vim-maketable') " {{{

  xmap ;t :Maketable!<CR>
  xmap ;T :Maketable<CR>

  call neobundle#untap()
endif " }}}

" CoffeeScript
if neobundle#tap('vim-coffee-script') " {{{

  nnoremap <silent> <C-C> :CoffeeCompile vert <CR><C-w>h
  augroup VimCoffeeScript
    autocmd!
    autocmd BufRead,BufNewFile,BufReadPre *.coffee   set filetype=coffee
    autocmd FileType coffee    setlocal sw=2 sts=2 ts=2 et
    autocmd QuickFixCmdPost * nested cwindow | redraw! 
  augroup END

  call neobundle#untap()
endif " }}}

" SASS
if neobundle#tap('sass-compile.vim') " {{{

  let g:sass_compile_cdloop = 5
  let g:sass_compile_auto = 0
  let g:sass_compile_file = ['scss', 'sass']
  let g:sass_compile_cssdir = ['css', 'stylesheet']

  call neobundle#untap()
endif " }}}

" }}}

if neobundle#tap('vim-json') " {{{

  let g:vim_json_syntax_conceal = 0

  call neobundle#untap()
endif " }}}

" }}}

" Auxiliary {{{
if neobundle#tap('vim-commentary') " {{{

  nnoremap ;c :Commentary<CR>
  vnoremap ;c :Commentary<CR>

  call neobundle#untap()
endif " }}}

if neobundle#tap('switch.vim') " {{{

  nnoremap ;s :Switch<CR>

  call neobundle#untap()
endif " }}}

if neobundle#tap('vim-easy-align') " {{{

  vmap <Enter> <Plug>(EasyAlign)

  call neobundle#untap()
endif " }}}

if neobundle#tap('vim-submode') " {{{

  let g:submode_keep_leaving_key = 1

  " tab moving
  call submode#enter_with('changetab', 'n', '', 'gt', 'gt')
  call submode#enter_with('changetab', 'n', '', 'gT', 'gT')
  call submode#map('changetab', 'n', '', 't', 'gt')
  call submode#map('changetab', 'n', '', 'T', 'gT')

  " resize window
  call submode#enter_with('winsize', 'n', '', '[s]>', '<C-w>>')
  call submode#enter_with('winsize', 'n', '', '[s]<', '<C-w><')
  call submode#enter_with('winsize', 'n', '', '[s]+', '<C-w>+')
  call submode#enter_with('winsize', 'n', '', '[s]-', '<C-w>-')
  call submode#map('winsize', 'n', '', '>', '<C-w>>')
  call submode#map('winsize', 'n', '', '<', '<C-w><')
  call submode#map('winsize', 'n', '', '+', '<C-w>+')
  call submode#map('winsize', 'n', '', '-', '<C-w>-')

  call neobundle#untap()
endif " }}}

if neobundle#tap('vim-quickrun') " {{{

  let g:quickrun_config = {}
  let g:quickrun_config._ = {
        \ 'runner':'vimproc',
        \ 'outputter/buffer/split' : ':botright 5sp',
        \ 'runner/vimproc/updatetime' : 60,
        \ 'outputter/buffer/close_on_empty' : 1,
        \ }

  nmap ;r <Plug>(quickrun)

  call neobundle#untap()
endif " }}}

" }}}

" Search {{{

if neobundle#tap('incsearch.vim') " {{{

  set hlsearch
  let g:incsearch#auto_nohlsearch = 1

  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)
  map n  <Plug>(incsearch-nohl-n)
  map N  <Plug>(incsearch-nohl-N)

  if neobundle#tap('incsearch-fuzzy.vim') " {{{

    map z/ <Plug>(incsearch-fuzzy-/)
    map z? <Plug>(incsearch-fuzzy-?)
    map zg/ <Plug>(incsearch-fuzzy-stay)

    call neobundle#untap()
  endif " }}}

  if neobundle#tap('incsearch-migemo.vim') " {{{

    map m/ <Plug>(incsearch-migemo-/)
    map m? <Plug>(incsearch-migemo-?)
    map mg/ <Plug>(incsearch-migemo-stay)

    call neobundle#untap()
  endif " }}}

  if neobundle#tap('vim-anzu') " {{{

    map n <Plug>(incsearch-nohl)<Plug>(anzu-n-with-echo)
    map N <Plug>(incsearch-nohl)<Plug>(anzu-N-with-echo)

    call neobundle#untap()
  endif " }}}

  if neobundle#tap('vim-asterisk') " {{{

    map *   <Plug>(incsearch-nohl)<Plug>(asterisk-*)
    map g*  <Plug>(incsearch-nohl)<Plug>(asterisk-g*)
    map #   <Plug>(incsearch-nohl)<Plug>(asterisk-#)
    map g#  <Plug>(incsearch-nohl)<Plug>(asterisk-g#)

    map z*  <Plug>(incsearch-nohl0)<Plug>(asterisk-z*)
    map gz* <Plug>(incsearch-nohl0)<Plug>(asterisk-gz*)
    map z#  <Plug>(incsearch-nohl0)<Plug>(asterisk-z#)
    map gz# <Plug>(incsearch-nohl0)<Plug>(asterisk-gz#)

    call neobundle#untap()
   endif " }}}

  call neobundle#untap()
endif " }}}

if neobundle#tap('clever-f.vim') " {{{

  let g:clever_f_smart_case = 1
  let g:clever_f_across_no_line = 1
  let g:clever_f_use_migemo = 1

  call neobundle#untap()
endif " }}}

if neobundle#tap('vim-easymotion') " {{{

  vnoremap [s] <NOP>
  vmap s [s]

  nmap [s]/ <Plug>(easymotion-bd-f2)
  vmap [s]/ <Plug>(easymotion-bd-f2)
  map ;l <Plug>(easymotion-bd-jk)
  map ;w <Plug>(easymotion-bd-w)

  let g:EasyMotion_do_mapping = 0
  let g:EasyMotion_use_migemo = 1
  let g:EasyMotion_use_upper = 1
  let g:EasyMotion_smartcase = 1

  call neobundle#untap()
endif " }}}

" }}}

" View {{{

if neobundle#tap('indentLine') " {{{

  let g:indentLine_color_term = 239
  augroup IndentLine
    autocmd!
    autocmd InsertEnter * IndentLinesDisable
    autocmd InsertLeave * IndentLinesEnable
  augroup END

  call neobundle#untap()
endif " }}}

if neobundle#tap('foldCC') " {{{

  set foldtext=FoldCCtext()
  let g:foldCCtext_tail = 'printf(" %s[%4d lines Lv%-2d]%s", v:folddashes, v:foldend-v:foldstart+1, v:foldlevel, v:folddashes)'

  call neobundle#untap()
endif " }}}

" }}}

" Other {{{

if neobundle#tap('excitetranslate-vim') " {{{

  xnoremap ;e :ExciteTranslate<CR>

  call neobundle#untap()
endif  " }}}

if neobundle#tap('open-browser.vim') " {{{

  nmap gs <Plug>(openbrowser-smart-search)
  vmap gs <Plug>(openbrowser-smart-search)

  call neobundle#untap()
endif " }}}

if neobundle#tap('dash.vim') " {{{

  nmap <silent> [Space]d <Plug>DashSearch

  call neobundle#untap()
endif " }}}

if neobundle#tap('vim-rooter') " {{{

  let g:rooter_disable_map = 1
  let g:rooter_autocmd_patterns = '*.go,*.rb,*.js,*.py,*.md,*.vim'
  let g:rooter_change_directory_for_non_project_files = 1
  let g:rooter_silent_chdir = 1

endif " }}}

" }}}

" My Plugin {{{

if neobundle#tap('vim-nightowl') " {{{

  colorscheme nightowl

  call neobundle#untap()
endif " }}}

" }}}

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
