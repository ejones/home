if filereadable($HOME."/.vim/autoload/pathogen.vim")
    let g:pathogen_disabled = []
    if !has('gui_running')
        call add(g:pathogen_disabled, 'vim-css-color')
        call add(g:pathogen_disabled, 'deoplete.nvim')
    endif
    execute pathogen#infect()
    Helptags
endif

" make changes to *this* file live
if !exists("g:did_liven_vimrc")
    let g:did_liven_vimrc=1
    au BufWritePost .vimrc so %
endif

" standard editor setup
set ai ml mls=5 et sts=4 ts=4 sw=4 ls=2 bs=2 bg=light
  \ stl=%t\ %y\ %r\ %m\ %{fugitive#statusline()}%=%c,%l/%L
  \ nu hid lazyredraw autoread splitright
  \ previewheight=20
  \ colorcolumn=100
  \ clipboard=unnamed
  \ wildmenu
filetype on
filetype indent plugin on
syntax on
let mapleader = ','

" Searching
set grepprg=rg\ --color=never
set wildignore+=*/.git/*,*/tmp/*,*.so,*.swp

" switch dir on BufEnter
au BufEnter * silent! lcd %:p:h

" Wrap left and right movement
set whichwrap+=<,>,h,l,[,]

" make gf work on new files too
noremap gf :e <cfile><CR>

" switch : and ;
noremap : ;
noremap ; :

" Colors - Solarized
if has("gui_running")
    colors solarized
endif

au! BufRead,BufNewFile *.snap setlocal ft=javascript.jsx

" It seems like by default, *.tpl is associated with smarty templates
au! BufRead,BufNewFile *.tpl setlocal ft=html

au! BufNewFile *.test.jsx ProjectDo %! node bin/gen-test.js %:p:h:h/%:t:r:r.jsx -

" smaller indent for markup and cs, js and css...
au! FileType \(xml\|html\|soy\|coffee\|javascript\|css\|less\|yaml\|ruby\) setlocal sw=2 sts=2

" cindent for C-like languages
au! FileType \(cs\|cpp\|c\|java\) setlocal cindent

" html has some long lines man
" json does not support line breaks in strings so by definition there may be
" really long lines
au! FileType \(html\|json\|css\|less\) setlocal nowrap foldmethod=indent | normal zR

au! FileType \(javascript\|javascript.jsx\) setlocal foldmethod=indent | normal zR

" Text files - wrap better
au! FileType \(text\|markdown\) setlocal wrap linebreak nolist

au! FileType python setlocal makeprg=python\ % errorformat=

command! -nargs=1 -complete=file ZipOpen
\  edit <args>
\| if !exists("b:zipfile")
\|   call zip#Browse("<args>")
\| endif

function! s:open_python_module(modname) abort
    let l:path = system('python -c "import inspect as I,"'.shellescape(a:modname).'" as M;'.
\                                  'print (I.getsourcefile(M))"')

    if v:shell_error
        echo l:path
        return
    endif

    let l:path = substitute(l:path, '\n', '', '')

    if !filereadable(l:path)
        let l:egg_ext = '.egg/'
        let l:idx = strridx(l:path, l:egg_ext)
        if l:idx != -1
            let l:egg_path = strpart(l:path, 0, l:idx + len(l:egg_ext) - 1)
            if filereadable(l:egg_path)
                " REVIEW: this seems to trigger zip.vim opening the zip file
                " within the zip file 
                let l:path = 'zipfile:'.l:egg_path.'::'.strpart(l:path, l:idx + len(l:egg_ext))
            endif
        endif
    endif

    exe 'edit '.fnameescape(l:path)
endfunction

command! -nargs=1 PyOpen call s:open_python_module("<args>")

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
au! BufNewFile \*scratch\* setlocal bt=nofile bh=hide noswf bl
command! -bar Scratch
\  let g:lastdir=expand("%:p:h")
\| wincmd o
\| wincmd v
\| exec "normal zz"
\| wincmd w
\| e \*scratch\*
\| exec "lcd ".g:lastdir

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

" Neosnippet
" Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

let g:neosnippet#snippets_directory='~/.vim/snippets'

" Deoplete
let g:deoplete#enable_at_startup = 1

" CtrlP
let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
let g:ctrlp_use_caching = 0

" RipGrep
let g:rg_highlight = 1
let g:rg_derive_root = 1

" Projectionist
let s:reporter_arg = '--reporters=' . expand('$HOME') . '/.js/reporters/jest-simple-reporter'
let s:yarn_dispatch = 'yarn --silent test /{basename}. ' . s:reporter_arg
let g:projectionist_heuristics = {
      \   'package.json&src/index.js*': {
      \     'src/*.jsx': {
      \       'type': 'source',
      \       'alternate': [
      \         'src/{dirname}/{basename}.less',
      \         'src/{dirname}/__tests__/{basename}.test.jsx'
      \       ],
      \       'dispatch': s:yarn_dispatch
      \     },
      \     'src/**/__tests__/*.test.jsx': {
      \       'type': 'test',
      \       'alternate': [
      \         'src/{dirname}/{basename}.jsx'
      \       ],
      \       'dispatch': s:yarn_dispatch
      \     },
      \     'src/*.less': {
      \       'type': 'style',
      \       'alternate': [
      \         'src/{dirname}/{basename}.jsx',
      \       ],
      \       'template': [
      \         '.{basename} {open}',
      \         '',
      \         '{close}'
      \       ],
      \     },
      \     'README.md': {'type': 'doc'},
      \     '*': {'make': 'arc lint --output summary'}
      \   },
      \   'Gemfile': {
      \     'app/models/*.rb': {
      \       'type': 'model',
      \       'alternate': [
      \         'db/schema.rb{lnum|nothing}',
      \         'spec/models/{}_spec.rb',
      \         'app/controllers/private_api/v1/{basename|plural}_controller.rb',
      \         'app/controllers/private_api/dashboard/v1/{basename|plural}_controller.rb',
      \         'app/controllers/public_api/v1/{basename|plural}_controller.rb',
      \         'app/controllers/admin/{basename|plural}_controller.rb'
      \       ]
      \     },
      \     'app/controllers/*_controller.rb': {
      \       'type': 'controller',
      \       'alternate': [
      \         'app/views/{}/index.html.haml{lnum|nothing}',
      \         'spec/controllers/{}_controller_spec.rb',
      \         'app/models/{basename|singular}.rb'
      \       ]
      \     },
      \     'app/views/*.html.haml': {
      \       'type': 'view',
      \       'alternate': 'app/controllers/{dirname}_controller.rb'
      \     },
      \     'spec/*_spec.rb': {
      \       'type': 'spec',
      \       'alternate': 'app/{}.rb'
      \     },
      \     'db/schema.rb': {'type': 'schema'},
      \     'README.md': {'type': 'doc'}
      \   }
      \ }

" Emmet.
let g:user_emmet_settings = {
\   'html': {
\       'indentation': '  '
\   }
\}

command! -nargs=* SubWord exec "%s/\\<" . expand("<cword>") . "\\>/" . <q-args>

" Leader mappings
nnoremap <Leader>w :bd<cr>
nnoremap <Leader>b :CtrlPBuffer<cr>
nnoremap <Leader>; :CtrlPCmdline<CR>

" selecting pasted text.
" from http://vim.wikia.com/wiki/Selecting_your_pasted_text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
