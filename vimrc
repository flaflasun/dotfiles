"-------------------------------------------------------------------------------
" flaflasun's .vimrc
"-------------------------------------------------------------------------------
" Basic: {{{

" Initialize {{{

if !1 | finish | endif

" Disable Vi compatible.
if has('vim_starting')
  "set nocompatible
endif

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

" Encoding {{{

set encoding=utf-8

" setting of terminal encoding.
if !has('gui_running')
  if &term == 'win32' || &term == 'win64'
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

function! s:make_tabline()  "{{{
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
    let s .= no . ':' . title
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
set listchars=tab:>-,trail:-,extends:>,precedes:>
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

" Auto-format {{{

" Disable automatically insert comment.
autocmd MyAutoCmd FileType * setl formatoptions-=ro | setl formatoptions+=mM
let g:execcmd_after_ftplugin = {
  \    '_': [
  \        'setlocal fo-=t fo-=c fo-=r fo-=o',
  \    ],
  \    'c': [
  \        'setlocal fo-=t fo-=c fo-=r fo-=o',
  \    ],
  \    'perl': [
  \        'setlocal fo-=t fo-=c fo-=r fo-=o',
  \    ],
  \}
let g:execcmd_after_indent = {
  \    '_': [
  \        'setlocal fo-=t fo-=c fo-=r fo-=o',
  \    ],
  \    'php': [
  \        'setlocal fo-=t fo-=c fo-=r fo-=o',
  \    ],
  \}

" }}}

" Complete {{{

set nowildmenu
set wildmode=list:longest,full
set showfulltag

set wildoptions=tagfile

set completeopt=menu,preview

set complete=.

set pumheight=20

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
  autocmd FileType cpp setlocal path=.,/usr/include,/usr/local/include,/usr/lib/c++/v1
  autocmd BufRead,BufNewFile *.md set filetype=markdown
augroup END

" Golang {{{

exe 'set rtp+='.globpath($GOPATH, 'src/github.com/nsf/gocode/vim')

" }}}

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
inoremap <silent><C-a> <C-o>^
" move to end.
inoremap <silent><C-e> <C-o>$
" insert tab.
inoremap <C-t> <C-v><TAB>
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

nnoremap <C-j> <C-e>gj
nnoremap <C-k> <C-y>gk

nnoremap > >>
nnoremap < <<

nnoremap [Space] <NOP>
nmap <Space> [Space]

nnoremap <silent> [Space]s :<C-u>split<CR>
nnoremap <silent> [Space]v :<C-u>vsplit<CR>

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

nnoremap <silent> [Space]tn :<C-u>tabnew<CR>

nnoremap <silent> [Space]t2 :<C-u>setl shiftwidth=2 softtabstop=2<CR>
nnoremap <silent> [Space]t4 :<C-u>setl shiftwidth=4 softtabstop=4<CR>
nnoremap <silent> [Space]t8 :<C-u>setl shiftwidth=8 softtabstop=8<CR>

" A .vimrc snippet that allows you to move around windows beyond tabs
nnoremap <silent> <Tab> :<C-u>wincmd w<CR>
nnoremap <silent> <S-Tab> :<C-u>wincmd W<CR>

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

" Disable netrw.vim
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
" }}}

" Setup {{{

if has('vim_starting')
  set runtimepath+=$NEOBUNDLE_PATH
endif

call neobundle#begin(expand($VIM_BUNDLE))

NeoBundleFetch 'Shougo/neobundle.vim'

" }}}

" List {{{
if neobundle#has_fresh_cache(expand('$MYVIMRC'))
  NeoBundleLoadCache
else

  NeoBundle 'Shougo/vimproc', {
        \ 'build' : {
        \   'windows' : 'make -f make_mingw32.mak',
        \   'cygwin' : 'make -f make_cygwin.mak',
        \   'mac' : 'make -f make_mac.mak',
        \   'unix' : 'make -f make_unix.mak',
        \ }}

  NeoBundleLazy 'Shougo/vimshell', { 'depends' : [ 'Shougo/vimproc.vim' ] }

  NeoBundleLazy 'Shougo/vimfiler.vim', { 'depends' : [ 'Shougo/unite.vim' ] }

  NeoBundleLazy 'Shougo/neocomplete'
  NeoBundleLazy 'ujihisa/neco-look', { 'depends' : [ 'Shougo/neocomplete' ] }

  " Snippets
  NeoBundleLazy 'Shougo/neosnippet'
  NeoBundle 'Shougo/neosnippet-snippets', { 'depends' : 'Shougo/neosnippet' }
  NeoBundle 'honza/vim-snippets', { 'depends' : 'Shougo/neosnippet' }

  " Unite
  NeoBundle 'Shougo/unite.vim'
  NeoBundle 'Shougo/unite-help', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'Shougo/unite-outline', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'Shougo/unite-session', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'Shougo/unite-ssh', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'thinca/vim-unite-history', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'tsukkee/unite-tag', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'ujihisa/unite-colorscheme', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'ujihisa/unite-font', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'ujihisa/unite-locate', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'osyo-manga/unite-highlight', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'pasela/unite-webcolorname', { 'depends' : [ 'Shougo/unite.vim' ] }
  "NeoBundle 'rhysd/unite-ruby-require.vim', { 'depends' : [ 'Shougo/unite.vim' ] }
  NeoBundle 'Shougo/neomru.vim', { 'depends' : [ 'Shougo/unite.vim' ] }
  "NeoBundle 'Shougo/neobundle-vim-scripts'

  NeoBundle 'thinca/vim-ref'

  " Operater
  NeoBundleLazy 'tpope/vim-commentary'

  " Text object
  NeoBundle 'kana/vim-textobj-user'
  NeoBundle 'kana/vim-textobj-entire', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'kana/vim-textobj-function', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'kana/vim-textobj-indent', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'rhysd/vim-textobj-ruby', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'osyo-manga/vim-textobj-multiblock', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'osyo-manga/vim-textobj-multitextobj', { 'depends' : 'kana/vim-textobj-user' }
  NeoBundle 'osyo-manga/vim-textobj-blockwise', { 'depends' : 'kana/vim-textobj-user' }

  " Git
  NeoBundleLazy 'tpope/vim-fugitive'
  NeoBundleLazy 'cohama/agit.vim'

  " Gist
  NeoBundleLazy 'mattn/gist-vim', { 'depends' : [ 'mattn/webapi-vim' ] }

  " Ruby
  NeoBundle 'vim-ruby/vim-ruby'
  NeoBundleLazy 'taka84u9/vim-ref-ri', { 'depends' : [ 'Shougo/unite.vim', 'thinca/vim-ref' ] }
  NeoBundleLazy 't9md/vim-ruby-xmpfilter'
  NeoBundle 'tpope/vim-rails'
  NeoBundleLazy 'basyura/unite-rails', { 'depends' : [ 'Shougo/unite.vim' ] }

  NeoBundleLazy 'kana/vim-niceblock', {
        \   'mappings' : '<Plug>',
        \ }

  NeoBundleLazy 'alpaca-tc/alpaca_tags', {
       \ 'depends': ['Shougo/vimproc'],
       \ 'autoload' : {
       \   'commands' : [
       \     { 'name' : 'AlpacaTagsBundle', 'complete': 'customlist,alpaca_tags#complete_source' },
       \     { 'name' : 'AlpacaTagsUpdate', 'complete': 'customlist,alpaca_tags#complete_source' },
       \     'AlpacaTagsSet', 'AlpacaTagsCleanCache', 'AlpacaTagsEnable', 'AlpacaTagsDisable', 'AlpacaTagsKillProcess', 'AlpacaTagsProcessStatus',
       \ ],
       \ }}

  " Golang
  NeoBundleLazy 'vim-jp/vim-go-extra'

  " Coffee Script
  NeoBundleLazy 'kchmck/vim-coffee-script'

  " Markdown
  NeoBundle 'tpope/vim-markdown'

  " Ansible
  NeoBundleLazy 'chase/vim-ansible-yaml'

  " Templete
  NeoBundle 'mattn/sonictemplate-vim'

  NeoBundle 'kana/vim-submode'
  NeoBundle 'osyo-manga/vim-anzu'
  NeoBundle 'tpope/vim-surround'
  NeoBundle 'majutsushi/tagbar'

  " Others
  NeoBundleLazy 'mattn/excitetranslate-vim', { 'depends': 'mattn/webapi-vim' }
  NeoBundle 'mattn/webapi-vim'
  NeoBundle 'tyru/open-browser.vim'
  NeoBundle 'kannokanno/previm'

  NeoBundle 'scrooloose/syntastic'

  NeoBundle 'haya14busa/vim-asterisk'
  NeoBundle 'tpope/vim-surround'
  NeoBundle 'rhysd/clever-f.vim'
  NeoBundle 'Lokaltog/vim-easymotion'
  NeoBundleLazy 'AndrewRadev/switch.vim'
  NeoBundleLazy 'sjl/gundo.vim'
  NeoBundle 'Yggdroot/indentLine'
  NeoBundle 'LeafCage/foldCC'
  NeoBundle 'junegunn/vim-easy-align'

  NeoBundle 'vim-jp/vimdoc-ja'

  " Colorscheme
  NeoBundle 'tomasr/molokai'
  NeoBundle 'altercation/vim-colors-solarized'
  NeoBundle 'flaflasun/vim-nightowl'

  NeoBundleSaveCache
endif

call neobundle#end()

filetype plugin indent on

if !has('vim_starting')
  " Installation check.
  NeoBundleCheck
endif

" }}}

" Configurations  {{{

if neobundle#tap('vimshell') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'VimShell', 'VimShellPop', 'VimShellTab' ]
        \   }
        \ })

  let g:vimshell_max_command_history = 0
  let g:vimshell_prompt = 'vimshell % '
  let g:vimshell_secondary_prompt = '> '
  let g:vimshell_user_prompt = '$USER ."@" .hostname() ." [" .getcwd() ."]"'

  nnoremap ;vp  :<C-u>VimShellPop -toggle<CR>
  nnoremap ;vb  :<C-u>VimShellBufferDir<CR>
  nnoremap ;vd  :<C-u>VimShellCurrentDir<CR>
  nnoremap ;vv  :<C-u>VimShell<CR>

endif " }}}

if neobundle#tap('vimfiler.vim') "{{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'VimFilerExplorer' ]
        \   }
        \ })

  let g:vimfiler_safe_mode_by_default = 1
  let g:unite_kind_file_use_trashbox = 1
  let g:vimfiler_as_default_explorer = 1
  let g:vimfiler_enable_auto_cd = 1

  nnoremap ;e :<C-u>VimFilerExplorer<CR>

  if has('mac')
    let g:vimfiler_quick_look_command = 'qlmanage -p'
    autocmd FileType vimfiler nmap <buffer> V <Plug>(vimfiler_quick_look)
  endif

endif " }}}

if neobundle#tap('neocomplete') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'insert' : 1,
        \   }
        \ })

  let g:acp_enableAtStartup = 0
  let g:neocomplete#enable_at_startup = 1

  let s:hooks = neobundle#get_hooks('neocomplete.vim')
  function! s:hooks.on_source(bundle)
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
  endfunction

  " neocomplete.vim Key-mappings.
  inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><C-y>  neocomplete#close_popup()

endif " }}}

if neobundle#tap('neosnippet') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'insert' : 1,
        \     'filetype' : 'snippet',
        \     'commands' : [ 'NeoSnippetEdit', 'NeoSnippetSource' ],
        \     'filetypes' : [ 'nsnippet' ],
        \     'unite_sources' :
        \       ['snippet', 'neosnippet/user', 'neosnippet/runtime']
        \   }
        \ })

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

endif " }}}

if neobundle#tap('neosnippet-snippets') " {{{

endif " }}}

if neobundle#tap('vim-snippets') " {{{

  let g:neosnippet#snippets_directory = $DOTVIM . '/snippets' . ',' . $VIM_BUNDLE . '/vim-snippts/snippets'

endif " }}}

if neobundle#tap('unite.vim') " {{{

  " Plugin key-mappings.
  nnoremap [unite] <NOP>
  xnoremap [unite] <NOP>
  nmap ;u [unite]
  xmap ;u [unite]

  nnoremap <silent> [unite]b :<C-u>Unite -buffer-name=buffer buffer<CR>
  nnoremap <silent> [unite]c
        \:<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>
  nnoremap <silent> [unite]g :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
  nnoremap <silent> [unite]h :<C-u>Unite -buffer-name=help help -start-insert<CR>
  nnoremap <silent> [unite]k :<C-u>Unite change jump<CR>
  nnoremap <silent> [unite]m :<C-u>Unite -buffer-name=mapping mapping<CR>
  nnoremap <silent> [unite]o
        \ :<C-u>Unite -buffer-name=outline outline -start-insert -resume<CR>
  nnoremap <silent> [unite]r
        \ :<C-u>Unite -buffer-name=register register history/yank<CR>
  nnoremap <silent> [unite]s :<C-u>Unite source<CR>
  nnoremap <silent> [unite]u :<C-u>Unite -no-split<Space>
  nnoremap <silent> [unite]t :<C-u>Unite -buffer-name=tag tag<CR>
  nnoremap <silent> [unite]w :<C-u>Unite -buffer-name=window window<CR>

  if !exists('g:unite_source_menu_menus')
    let g:unite_source_menu_menus = {}
  endif

  " replace grep with ag.
  if executable('ag')
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
    let g:unite_source_grep_recursive_opt = ''
  endif

  " unite-session.vim {{{
  let g:unite_source_session_enable_auto_save = 1
  " }}}

  " unite-rails.vim {{{
  nnoremap <silent> [unite]rv :<C-U>Unite rails/view<CR>
  nnoremap <silent> [unite]rm :<C-U>Unite rails/model<CR>
  nnoremap <silent> [unite]rc :<C-U>Unite rails/controller<CR>
  " }}}

  " neomru.vim {{{
  let g:neomru#time_format = '[%Y/%m/%d %H:%M:%S] '
  let g:neomru#file_mru_limit = 100
  let g:neomru#directory_mru_limit = 100

  nnoremap [unite]f :<C-u>Unite file_mru<CR>
  nnoremap [unite]d :<C-u>Unite directory_mru<CR>

  " Create Vim start page. {{{
  let g:unite_source_alias_aliases = {
        \  'startup_file_mru' : {
        \    'source': 'file_mru',
        \  },
        \  'startup_directory_mru' : {
        \    'source': 'directory_mru',
        \  },
        \ }

  call unite#custom_max_candidates('startup_file_mru', 5)
  call unite#custom_max_candidates('startup_directory_mru', 5)

  let g:unite_source_menu_menus.startup = {
        \   'description': 'startup menu',
        \   'command_candidates': [
        \     ['brank', 'edit'],
        \     ['vimrc', 'edit'.$MYVIMRC],
        \     ['gvimrc', 'edit'.$MYGVIMRC],
        \     ['unite file_mru', 'Unite file_mru'],
        \     ['unite directory_mru', 'Unite directory_mru'],
        \     ['unite session', 'Unite session'],
        \   ]
        \ }

  command! UniteStartup
        \ Unite
        \ output:echo:"===:file:mru:===":! startup_file_mru
        \ output:echo:":":!
        \ output:echo:"===:directory:mru:===":! startup_directory_mru
        \ output:echo:":":!
        \ output:echo:"===:menu:===":! menu:startup
        \ -hide-source-names
        \ -no-split

  function! s:GetBufByte()
    let byte = line2byte(line('$') + 1)
    if byte == -1
      return 0
    else
      return byte - 1
    endif
  endfunction

  "if has('vim_starting') && @% == '' && s:GetBufByte() == 0
  "  augroup MyAutoCmd
  "    autocmd!
  "    autocmd VimEnter * nested :UniteStartup
  "  augroup END
  "endif
  " }}}
  " }}}

endif " }}}

if neobundle#tap('vim-ref') "{{{

  let g:ref_use_vimproc=1
  let g:ref_refe_version=2
  let g:ref_refe_encoding = 'utf-8'

  autocmd FileType * nnoremap <silent><buffer> ;k :<C-u>Unite -start-insert -default-action=split ref/man<CR>
  autocmd FileType ruby nnoremap <silent><buffer> ;k :<C-u>Unite -start-insert -default-action=split ref/refe<CR>
  autocmd FileType python nnoremap <silent><buffer> ;k :<C-u>Unite -start-insert -default-action=split ref/pydoc<CR>

endif " }}}

if neobundle#tap('vim-commentary') "{{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'Commentary' ],
        \   }
        \ })

endif " }}}

if neobundle#tap('vim-fugitive') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'Gblame', 'Gdiff', 'Gstatus' ],
        \   }
        \ })

  nnoremap <silent> ;gb :Gblame<CR>
  nnoremap <silent> ;gd :Gdiff<CR>
  nnoremap <silent> ;gs :Gstatus<CR>

  let &statusline="%{winnr('$')>1?'['.winnr().'/'.winnr('$')"
        \ . ".(winnr('#')==winnr()?'#':'').']':''}\ "
        \ . "%{(&previewwindow?'[preview] ':'').expand('%:t:.')}"
        \ . "\ %=%m%y%{'['.(&fenc!=''?&fenc:&enc).','.&ff.']'}"
        \ . "%{fugitive#statusline()}"
        \ . "%{printf(' %5d/%d',line('.'),line('$'))}"

  endif " }}}

if neobundle#tap('agit.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'Agit', 'AgitFile' ],
        \   }
        \ })

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

endif " }}}

if neobundle#tap('gist-vim') "{{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'Gist' ],
        \   }
        \ })

  if has(s:is_windows)
  elseif has('mac')
    let g:gist_clip_command = 'pbcopy'
  else
    let g:gist_clip_command = 'xclip -selection clipboard'
  endif

  let g:gist_detect_filetype = 1

endif " }}}

if neobundle#tap('vim-ruby-xmpfilter') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : 'ruby'
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:xmpfilter_cmd = 'seeing_is_believing'
    autocmd FileType ruby nmap <buffer> <C-s>m <Plug>(seeing_is_believing-mark)
    autocmd FileType ruby xmap <buffer> <C-s>m <Plug>(seeing_is_believing-mark)
    autocmd FileType ruby imap <buffer> <C-s>m <Plug>(seeing_is_believing-mark)
    autocmd FileType ruby nmap <buffer> <C-s>c <Plug>(seeing_is_believing-clean)
    autocmd FileType ruby xmap <buffer> <C-s>c <Plug>(seeing_is_believing-clean)
    autocmd FileType ruby imap <buffer> <C-s>c <Plug>(seeing_is_believing-clean)
    autocmd FileType ruby nmap <buffer> <C-s>r <Plug>(seeing_is_believing-run_-x)
    autocmd FileType ruby xmap <buffer> <C-s>r <Plug>(seeing_is_believing-run_-x)
    autocmd FileType ruby imap <buffer> <C-s>r <Plug>(seeing_is_believing-run_-x)
  endfunction

endif " }}}

if neobundle#tap('vim-go-extra') "{{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : 'go'
        \   }
        \ })

  autocmd FileType go autocmd BufWritePre <buffer> Fmt

endif " }}}

if neobundle#tap('vim-coffee-script') "{{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : 'coffee'
        \   }
        \ })

  autocmd BufRead,BufNewFile,BufReadPre *.coffee   set filetype=coffee
  autocmd FileType coffee    setlocal sw=2 sts=2 ts=2 et
  autocmd QuickFixCmdPost * nested cwindow | redraw! 
  nnoremap <silent> <C-C> :CoffeeCompile vert <CR><C-w>h

endif " }}}

if neobundle#tap('vim-ansible-yaml') "{{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : 'yml'
        \   }
        \ })

endif " }}}

if neobundle#tap('sonictemplate-vim') "{{{

endif " }}}

if neobundle#tap('vim-submode') " {{{

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:submode_keep_leaving_key = 1
    " tab moving
    call submode#enter_with('changetab', 'n', '', 'gt', 'gt')
    call submode#enter_with('changetab', 'n', '', 'gT', 'gT')
    call submode#map('changetab', 'n', '', 't', 'gt')
    call submode#map('changetab', 'n', '', 'T', 'gT')
    " resize window
    call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
    call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
    call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>+')
    call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>-')
    call submode#map('winsize', 'n', '', '>', '<C-w>>')
    call submode#map('winsize', 'n', '', '<', '<C-w><')
    call submode#map('winsize', 'n', '', '+', '<C-w>+')
    call submode#map('winsize', 'n', '', '-', '<C-w>-')
    " TODO: Repeat last executed macro. umaku dekinai...
    " call submode#enter_with('macro/a', 'n', '', '@a', '@a')
    " call submode#map('macro/a', 'n', '', 'a', '@a')
  endfunction

endif " }}}

if neobundle#tap('vim-anzu') " {{{

  nmap n <Plug>(anzu-n-with-echo)
  nmap N <Plug>(anzu-N-with-echo)

endif " }}}

if neobundle#tap('vim-surround') " {{{

endif " }}}

if neobundle#tap('tagbar') " {{{

  let g:tagbar_type_go = {
        \ 'ctagstype' : 'go',
        \ 'kinds'     : [
        \   'p:package',
        \   'v:variables',
        \   't:type',
        \   'r:const',
        \   'f:function'
        \ ],
        \}

  nnoremap ;t :<C-u>TagbarToggle<CR>

endif " }}}

if neobundle#tap('excitetranslate-vim') "{{{

  call neobundle#config({
        \ 'autoload' : {
        \   'commands': ['ExciteTranslate']
        \   }
        \ })

  xnoremap ;e :ExciteTranslate<CR>

endif  " }}}

if neobundle#tap('open-browser.vim') "{{{

  nmap gs <Plug>(open-browser-wwwsearch)

  let s:hooks = neobundle#get('open-browser.vim')
  function! s:hooks.on_source(bundle)
    nnoremap <Plug>(open-browser-wwwsearch)
          \ :<C-u>call <SID>www_search()<CR>
    function! s:www_search()
      let search_word = input('Please input search word: ', '',
            \ 'customlist,wwwsearch#cmd_Wwwsearch_complete')
      if !empty(search_word)
        execute 'OpenBrowserSearch' escape(search_word, '"')
      endif
    endfunction
  endfunction

endif " }}}

if neobundle#tap('syntastic') " {{{

  let g:syntastic_mode_map = { 'mode': 'passive',
        \ 'active_filetypes': ['ruby'] }
  let g:syntastic_ruby_checkers = ['rubocop']

endif " }}}

if neobundle#tap('vim-asterisk') " {{{

  map *   <Plug>(asterisk-*)
  map #   <Plug>(asterisk-#)
  map g*  <Plug>(asterisk-g*)
  map g#  <Plug>(asterisk-g#)
  map z*  <Plug>(asterisk-z*)
  map gz* <Plug>(asterisk-gz*)
  map z#  <Plug>(asterisk-z#)
  map gz# <Plug>(asterisk-gz#)

endif " }}}

if neobundle#tap('clever-f.vim') " {{{

  let g:clever_f_smart_case = 1
  let g:clever_f_across_no_line = 1
  let g:clever_f_use_migemo = 1

endif " }}}

if neobundle#tap('vim-easymotion') " {{{

  nmap s <Plug>(easymotion-s2)
  let g:EasyMotion_use_migemo = 1
  let g:EasyMotion_use_upper = 1
  let g:EasyMotion_smartcase = 1

endif " }}}

if neobundle#tap('switch.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'Switch' ]
        \   }
        \ })

  nnoremap ;s :Switch<CR>

endif " }}}

if neobundle#tap('gundo.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'GundoToggle' ]
        \   }
        \ })

  nnoremap ;gu :<C-u>GundoToggle<CR>

endif " }}}

if neobundle#tap('indentLine') " {{{

  let g:indentLine_color_term = 239
  augroup MyAutoCmd
    autocmd InsertEnter * IndentLinesDisable
    autocmd InsertLeave * IndentLinesEnable
  augroup END

endif " }}}

if neobundle#tap('foldCC') " {{{

  set foldtext=FoldCCtext()
  let g:foldCCtext_tail = 'printf(" %s[%4d lines Lv%-2d]%s", v:folddashes, v:foldend-v:foldstart+1, v:foldlevel, v:folddashes)'

endif " }}}

if neobundle#tap('vim-easy-align') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'EasyAlign' ]
        \   }
        \ })

  vmap <Enter> <Plug>(EasyAlign)

endif " }}}

if neobundle#tap('vim-nightowl') " {{{

  colorscheme nightowl

endif " }}}

" }}}

" }}}

"-------------------------------------------------------------------------------
" Others: {{{

set mouse=a

set helplang& helplang=ja,en

set secure

" }}}