" Unite.vim {{{

nnoremap [unite] <NOP>
xnoremap [unite] <NOP>
nmap ;u [unite]
xmap ;u [unite]

nnoremap [unite]u :Unite<Space>
nnoremap <silent> ;e :<C-u>Unite
      \ -buffer-name=Filer file file/new<CR>
nnoremap <silent> ;b :<C-u>Unite -start-insert
      \ -buffer-name=bookmark bookmark<CR>
nnoremap <silent> ;d :<C-u>Unite -start-insert
      \ -buffer-name=directory_rec directory_rec/async:<CR>
nnoremap <silent> ;f :<C-u>Unite -start-insert
      \ -buffer-name=file_rec file_rec/async:<CR>

nnoremap <silent> [unite]b :<C-u>Unite
      \ -start-insert -buffer-name=buffer buffer<CR>
nnoremap [unite]c :<C-u>Unite grep:.
      \ -buffer-name=search-buffer<CR><C-R><C-W>
nnoremap [unite]g :<C-u>Unite grep:.
      \ -buffer-name=search-buffer<CR>
nnoremap <silent> [unite]h :<C-u>Unite
      \ -start-insert -buffer-name=help help<CR>
nnoremap <silent> [unite]j :<C-u>Unite
      \ -start-insert -buffer-name=jump jump<CR>
nnoremap <silent> [unite]k :<C-u>Unite
      \ -start-insert -buffer-name=change change jump<CR>
nnoremap <silent> [unite]/ :<C-u>Unite
      \ -buffer-name=search -start-insert line<CR>
nnoremap <silent> [unite]m :<C-u>Unite
      \ -start-insert -buffer-name=mapping mapping<CR>
nnoremap <silent> [unite]o :<C-u>Unite
      \ -start-insert -buffer-name=outline outline<CR>
nnoremap <silent> [unite]r :<C-u>Unite
      \ -start-insert -buffer-name=register register history/yank<CR>
nnoremap <silent> [unite]t :<C-u>Unite
      \ -start-insert -buffer-name=tag tag<CR>

call unite#custom#source('file_rec/async', 'ignore_pattern',
      \ '\(png\|gif\|jpeg\|jpg\|mp3\|mov\|wav\|avi\|mpg\)$')

if !exists('g:unite_source_menu_menus')
  let g:unite_source_menu_menus = {}
endif

" replace grep with ag.
if executable('ag')
  let g:unite_source_rec_async_command =
        \ ['ag', '--follow', '--nocolor', '--nogroup', '--hidden', '-g', '']
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''
endif

" }}}

" unite-session {{{

nnoremap <silent> [unite]s :<C-u>Unite -start-insert -buffer-name=session session<CR>
let g:unite_source_session_enable_auto_save = 1

" }}}

" unite-rails {{{

nnoremap <silent> [unite]rv :<C-U>Unite rails/view<CR>
nnoremap <silent> [unite]rm :<C-U>Unite rails/model<CR>
nnoremap <silent> [unite]rc :<C-U>Unite rails/controller<CR>

" }}}

" neomru.vim {{{

let g:neomru#time_format = '[%Y/%m/%d %H:%M:%S] '
let g:neomru#file_mru_limit = 500
let g:neomru#directory_mru_limit = 100

nnoremap <silent> [unite]f :<C-u>Unite -start-insert -buffer-name=file_mru file_mru<CR>
nnoremap <silent> [unite]d :<C-u>Unite -start-insert -buffer-name=dir_mru directory_mru<CR>

" }}}

" vim-ref {{{

let g:ref_use_vimproc=1
let g:ref_refe_version=2
let g:ref_refe_encoding = 'utf-8'

augroup MyAutoCmd
  autocmd FileType ruby nnoremap <silent><buffer> ;k :<C-u>Unite -start-insert -default-action=split ref/refe<CR>
  autocmd FileType python nnoremap <silent><buffer> ;k :<C-u>Unite -start-insert -default-action=split ref/pydoc<CR>
augroup END

" }}}

" memolist.vim {{{

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
nnoremap <silent> [memo]n :<C-u>MemoNew<CR>
nnoremap <silent> [memo]l :<C-u>MemoList<CR>
nnoremap <silent> [memo]g :<C-u>MemoGrep<CR>

" }}}

" unite-ghq {{{

nnoremap <silent> ;g :<C-u>Unite -start-insert -buffer-name=ghq ghq<cr>

" }}}

" Create Vim start page. {{{

function! s:get_buffer_byte()
  let byte = line2byte(line('$') + 1)
  if byte == -1
    return 0
  else
    return byte - 1
  endif
endfunction

command! UniteStartup
      \ Unite
      \ session file_mru file/new
      \ -no-split
      \ -start-insert
      \ -buffer-name=Startup

if has('vim_starting')
  if @% ==# '' && s:get_buffer_byte() == 0
    augroup MyAutoCmd
      autocmd VimEnter * UniteStartup
    augroup END
  endif
endif

" }}}
