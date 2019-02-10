if filereadable($HOME."/.vim/autoload/pathogen.vim")
  let g:pathogen_disabled = []
  if !has('gui_running')
    call add(g:pathogen_disabled, 'vim-css-color')
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
      \ incsearch
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

if exists('+undofile')
  set undofile
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

  autocmd FileType haxe setlocal matchpairs+=<:>
augroup END

augroup Templates
  autocmd!

  autocmd BufNewFile *.hx
        \ let p = expand("%:p:h") |
        \ let t = 'package ' . substitute(p[stridx(p, "src/") + 4:], '/', '.', 'g') . ';' .
        \   "\n\nclass " . expand("%:t:r") . " {\n}" |
        \ put! =t |
        \ $d
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

" Plugin Settings

" let g:terminal_command_window#continuation_pattern =
"       \ '\V\^\(...\|>\|irb\.\{-\}*\|[\d\+] pry\.\{-\}*\) '

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
let g:dispatch_compilers = {'sh -c "': '', 'arc lint': 'yarn', 'bundle exec': ''}
let g:dispatch_terminal_start_mods = 'belowright vertical'

" Emmet
let g:user_emmet_settings = {
      \   'html': {
      \       'indentation': '  '
      \   }
      \}

" Markdown Preview
let g:vim_markdown_preview_github = 1

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

if has('terminal')
  " " Edit command line in :terminal
  " tnoremap <CR> <C-W>:call terminal_command_window#add_and_execute_line('')<CR>
  " tnoremap <C-F> <C-W>:call terminal_command_window#edit_line('')<CR>

  tnoremap <C-W>; <C-W>:
endif

if filereadable(expand("~/.work/vimrc"))
  source ~/.work/vimrc
endif
