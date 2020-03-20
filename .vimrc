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

" Diff
set diffopt+=iwhite

set runtimepath+=~/.skim

" Terminal overrides
if !has('gui')
  " For some reason, when running in a 256 color terminal, terminal mode seems
  " to be converting ANSI color 7 to a 256 color equivalent. In the case of
  " solarized's 16 color palette, this ends up being much darker. So force 16
  " color mode.
  set t_Co=16
endif

filetype plugin indent on
syntax on
colors solarized

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

" Screen
function! s:pick_screen() abort
  let l:screens = filter(systemlist('screen -ls'), 'v:val =~# "^\\s"')
  let l:choices = extend(['Pick a screen:'], map(copy(l:screens), '(v:key + 1) . ". " . v:val'))
  let l:selected_index = len(l:screens) ==# 1 ? 0 : inputlist(l:choices) - 1
  let l:selected_screen = matchstr(get(l:screens, l:selected_index), '\S\+')
  call term_start(['screen', '-r', l:selected_screen], {'term_finish': 'close'})
endfunction

function! s:launch_screen(name) abort
  if empty(a:name)
    call s:pick_screen()
    return
  endif
  call term_start('screen -mDRS ' . a:name, {'term_finish': 'close'})
endfunction

command! -nargs=* Screen call s:launch_screen(<q-args>)

command! -range Wclip silent <line1>,<line2>w! ~/.clip.txt

" Fugitive
command! -nargs=0 Gdups Gdiff @{u}
command! -nargs=0 Grups Gread @{u}:%
command! -nargs=0 Gdmbs execute 'Gdiff ' . system('git merge-base origin @')
command! -nargs=0 Grmbs execute 'Gread ' . trim(system('git merge-base origin @')) . ':%'
command! -nargs=0 Glcherry Gsplit! log --cherry-pick ...origin
command! -nargs=* Gpoh Git push origin HEAD <args>

command! -nargs=? Feature
      \ if empty(<q-args>) | execute 'Merginal' |
      \ elseif <q-args> =~ ' ' | execute 'Git checkout -b' <q-args> | execute 'Git branch --set-upstream-to=origin/master' |
      \ else | execute 'Git checkout -b' <q-args> 'origin/master' |
      \ endif

" Tools
command! -nargs=* Arc <mods> topleft vertical call term_start(['arc', <f-args>], {'term_cols': 100, 'env': {'TERM': 'xterm-mono'}})
command! -nargs=* Yarn <mods> terminal yarn <args>

command! -range=% Format
      \ let b:format_top = line('w0') |
      \ let b:format_line = line('.') |
      \ if &filetype ==# 'python' |
      \ execute <q-line1> . ',' . <q-line2> '! autopep8 --max-line-length=100 -' |
      \ else |
      \ execute <q-line1> . ',' . <q-line2> '! yarn run -s prettier --parser'
      \   (&filetype ==# 'scss' ? 'scss' : 'babylon') |
      \ endif |
      \ execute 'normal' b:format_top . 'zt' . b:format_line . 'gg'

let s:test_term_cmd = 'ProjectDo bot vert term '
let s:jest_term_test_arg = '"%:r:s?\(test\)\@<!$?.test?\\."'
command! -nargs=* Test
      \ if &filetype ==# 'python' |
      \ execute s:test_term_cmd .
      \   'ptw %:h:s?^tests/??/%:t:s?^test_?? tests/%:h:s?^tests/??/test_%:t:s?^test_?? -- -vv' |
      \ elseif <q-args> ==# 'dbg' |
      \ execute s:test_term_cmd .
      \   'yarn node inspect node_modules/.bin/jest ' . s:jest_term_test_arg |
      \ elseif <q-args> ==# 'cov' |
      \ execute s:test_term_cmd .
      \   'yarn run jest ' . s:jest_term_test_arg . ' --coverage --coverage-reporters lcov' |
      \ execute 'term sh -c "cd coverage/lcov-report/ && python -mhttp.server 5000"' |
      \ else |
      \ execute s:test_term_cmd .
      \   'yarn run jest --watch -u ' . s:jest_term_test_arg . (empty(<q-args>) ? '' : ' ' . <q-args>) |
      \ endif

command! -nargs=0 Console
      \ if &filetype ==# 'python' |
      \ execute 'ProjectDo term ipython -c "from %:r:s?/?.? import *" -i' |
      \ else |
      \ call term_start([
      \   'node', '-e',
      \   'require("@babel/register")({cwd: ' . json_encode(projectionist#path()) . '}); ' .
      \   'const mod = require("./' . expand('%:r:r') . '");' .
      \   'require("repl").start({}).context.' . expand('%:r:r') . ' = mod.default || mod'
      \ ], {'env': {'NODE_ENV': 'test'}}) |
      \ endif


" Built-in plugins
runtime ftplugin/man.vim

" Plugin Settings

" Neosnippet
let g:neosnippet#snippets_directory='~/.vim/snippets'

" Deoplete
let g:deoplete#enable_at_startup = 1

" RipGrep
let g:rg_highlight = 1
let g:rg_derive_root = 1
let g:rg_command = "rg --vimgrep --type-add=\"jstest:*.*test.js\" --type-add=\"jstest:*.*test.jsx\"" .
      \ " --type-add=\"pytest:test_*.py\""

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
let g:mapleader = ','

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
nnoremap <Leader>e :exe 'SK '.fnamemodify(fugitive#repo().git_dir, ':h')<CR>
nnoremap <Leader>m :call skim#run(skim#wrap('SKIM', {'source': ctrlp#mrufiles#list('raw')}))<CR>

" selecting pasted text.
" from http://vim.wikia.com/wiki/Selecting_your_pasted_text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

if has('terminal')
  tnoremap <C-W>; <C-W>:
  command! Rerun call term_start(job_info(term_getjob(''))['cmd'], {'curwin': 1})
endif

if filereadable(expand("~/.work/vimrc"))
  source ~/.work/vimrc
endif
