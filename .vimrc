if filereadable($HOME."/.vim/autoload/pathogen.vim")
  let g:pathogen_disabled = []
  if !has('gui_running')
    call add(g:pathogen_disabled, 'vim-css-color')
    call add(g:pathogen_disabled, 'deoplete.nvim')
  endif
  execute pathogen#infect()
  Helptags
endif

" make changes to vimrc live
if !exists("g:did_liven_vimrc")
  let g:did_liven_vimrc = 1
  autocmd BufWritePost {.,}vimrc source %
endif

" Settings
set autoindent
      \ autoread
      \ autowrite
      \ modeline
      \ modelines=5
      \ expandtab
      \ softtabstop=2
      \ tabstop=2
      \ shiftwidth=2
      \ laststatus=2
      \ backspace=2
      \ statusline=%t\ %y\ %r\ %m\ %{fugitive#statusline()}%=%c,%l/%L
      \ lazyredraw
      \ splitright
      \ incsearch
      \ hidden
      \ history=200
      \ number
      \ relativenumber
      \ previewheight=20
      \ colorcolumn=100
      \ clipboard=unnamed
      \ wildmenu
      \ wildmode=longest:full,full
      \ cmdheight=2
      \ linebreak
      \ showcmd

if exists('+breakindent')
  set breakindent showbreak=\ +
endif

" Searching
set grepprg=rg\ --color=never
set wildignore+=*/.git/*,*/tmp/*,*.so,*.swp

" Wrap left and right movement
set whichwrap+=<,>,h,l,[,]

filetype plugin indent on
syntax on

" Colors - Solarized
if has("gui_running")
  colors solarized
endif

augroup Misc
  autocmd! 
  autocmd BufEnter * silent! lcd %:p:h " switch dir on BufEnter
augroup END

augroup FTCheck
  autocmd!
  autocmd BufRead,BufNewFile *.snap setlocal ft=javascript.jsx
augroup END

augroup FTOptions
  autocmd!

  " cindent for C-like languages
  autocmd FileType \(cs\|cpp\|c\|java\) setlocal cindent

  autocmd FileType \(html\|json\|css\|less\|javascript\|javascript.jsx\)
        \ setlocal foldmethod=indent | normal zR

  autocmd FileType python setlocal makeprg=python\ % errorformat= sts=4 sw=4 ts=4
augroup END

" Switch Projects - switches to a recently-used file in a project that matches
" the given name
function! s:open_project(command, name) abort
  let l:files = filter(ctrlp#mrufiles#list('raw'),
        \ "v:val =~# '^" . expand('$HOME') . "/" . a:name . "'")

  if empty(l:files)
    let l:files = glob("$HOME/" . a:name . '*/*.*', 0, 1)
  endif

  if empty(l:files)
    return 'echoerr "No files found"'
  endif

  return a:command . ' ' . fnameescape(l:files[0])
endfunction

command! -nargs=1 Eproject execute s:open_project('edit', "<args>")
command! -nargs=1 Sproject execute s:open_project('split', "<args>")
command! -nargs=1 Vproject execute s:open_project('vsplit', "<args>")
command! -nargs=1 Tproject execute s:open_project('tabedit', "<args>")

" Scratch
command! -bar -nargs=? -bang Scratch
      \ :silent enew<bang> |
      \ set buftype=nofile bufhidden=hide noswapfile buflisted filetype=<args> modifiable

command! -nargs=* SubWord exec "%s/\\<" . expand("<cword>") . "\\>/" . <q-args>

function! s:term_edit_line(buf) abort
  let buf = bufnr(a:buf)

  call term_sendkeys(buf, "\<C-a>\<C-k>")
  call term_wait(buf)
  let prompt = term_getline(buf, '.')

  10split enew
  setlocal buftype=nofile
        \ bufhidden=unload
        \ noswapfile
        \ buflisted
        \ modifiable

  put! =getbufline(buf, 1, '$')
  execute '%substitute/\V\^' . substitute(prompt, '\\\|/', '\\\0', 'g') . '//'

  execute 'nnoremap <buffer> <C-C> :call <SID>term_finish_editing("", ' . buf . ')<CR>'
  execute 'inoremap <buffer> <C-C> <C-O>:call <SID>term_finish_editing("", ' . buf . ')<CR>'
  execute 'vnoremap <buffer> <C-C> :<C-U>call <SID>term_finish_editing("", ' . buf . ')<CR>'
  execute 'nnoremap <buffer> <Enter> :call <SID>term_finish_editing("", ' . buf . ')<CR><CR>'
  execute 'inoremap <buffer> <Enter> <C-O>:call <SID>term_finish_editing("", ' . buf . ')<CR><CR>'
  execute 'vnoremap <buffer> <Enter> :<C-U>call <SID>term_finish_editing("", ' . buf . ')<CR><CR>'
endfunction

function! s:term_finish_editing(edit_buf, term_buf) abort
  let edit_buf = bufnr(a:edit_buf)
  let term_buf = bufnr(a:term_buf)
  let edit_buf_info = getbufinfo(edit_buf)[0]
  let edited_command = getbufline(edit_buf, edit_buf_info.lnum)[0]

  call term_sendkeys(term_buf, edited_command)
  call term_wait(term_buf)

  execute 'bunload! ' . edit_buf
  execute 'buffer ' . term_buf
endfunction

" Plugin Settings

" Neosnippet
let g:neosnippet#snippets_directory='~/.vim/snippets'

" Deoplete
let g:deoplete#enable_at_startup = 1

" CtrlP
let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
let g:ctrlp_use_caching = 0

" RipGrep
let g:rg_highlight = 1
let g:rg_derive_root = 1

" Dispatch
let g:dispatch_compilers = {'sh -c "': ''}

" Emmet
let g:user_emmet_settings = {
      \   'html': {
      \       'indentation': '  '
      \   }
      \}

" Mappings
let mapleader = ','

" switch : and ;
noremap : ;
noremap ; :

" v_if - text object for file under cursor
function! s:select_cursor_file() abort
  let l:cfile = expand("<cfile>")
  if l:cfile == "" || !search(l:cfile, "b", line("."))
    return
  endif
  exe "normal v".(len(l:cfile) - 1)."l"
endfunction

vnoremap if :<C-U>call <SID>select_cursor_file()<CR>
onoremap if :call <SID>select_cursor_file()<CR>

" Neosnippet mappings
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

nnoremap <Leader>w :bd<CR>

" selecting pasted text.
" from http://vim.wikia.com/wiki/Selecting_your_pasted_text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Edit command line in :terminal
if has('terminal')
  tnoremap <C-F> <C-W>:call <SID>term_edit_line('')<CR>
endif

if filereadable(expand("~/.work/vimrc"))
  source ~/.work/vimrc
endif
