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
set ai ml mls=5 et sts=4 ts=4 sw=4 ls=2 bs=2 hls bg=light
  \ stl=%t\ %y\ %r\ %m\ %{fugitive#statusline()}%=%c,%l/%L
  \ nu hid lazyredraw autoread splitright
  \ previewheight=20
  \ colorcolumn=100
  \ clipboard=unnamed
filetype on
filetype indent plugin on
syntax on
let mapleader = ','

fu! MaybeSource(f)
    if filereadable(a:f)
        exec 'so '.a:f
    endif
endfu

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

" Git

call MaybeSource($HOME.'/.vim/plugin/fugitive.vim')

" Colors - Solarized
if has("gui_running")
    colors solarized
endif

au! BufRead,BufNewFile *.snap setlocal ft=javascript.jsx

" It seems like by default, *.tpl is associated with smarty templates
au! BufRead,BufNewFile *.tpl setlocal ft=html

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

function! PyOpen(modname)
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

command! -nargs=1 PyOpen call PyOpen("<args>")

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
function! SelectCursorFile()
    let l:cfile = expand("<cfile>")
    if l:cfile == "" || !search(l:cfile, "b", line("."))
        return
    endif
    exe "normal v".(len(l:cfile) - 1)."l"
endfunction

vnoremap if :<C-U>call SelectCursorFile()<CR>
onoremap if :call SelectCursorFile()<CR>

" Neosnippet
" Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

let g:neosnippet#snippets_directory='~/.vim/snippets'

" Deoplete
let g:deoplete#enable_at_startup = 1

" NERDTREE
let g:NERDTreeShowHidden=1
let g:NERDTreeQuitOnOpen=1
let g:NERDTreeIgnore=['\~$', '\.sw[op]$']

" CtrlP
let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
let g:ctrlp_use_caching = 0

nnoremap <Leader>; :CtrlPCmdline<CR>

" RipGrep
let g:rg_highlight = 1
let g:rg_derive_root = 1

" Projectionist
let g:projectionist_heuristics = {
      \   '*.jsx': {
      \     '*.jsx': {
      \       'type': 'source',
      \       'alternate': [
      \         '{dirname}/__tests__/{basename}.test.jsx',
      \         '{dirname}/{basename}.less'
      \       ],
      \       'dispatch': 'yarn --silent test /%:r'
      \     },
      \     '**/__tests__/*.test.jsx': {
      \       'type': 'test',
      \       'alternate': '{dirname}/{basename}.jsx',
      \       'dispatch': 'yarn --silent test /%:r'
      \     },
      \     '*.less': {
      \       'type': 'style',
      \       'alternate': '{dirname}/{basename}.less'
      \     },
      \     '*': {'make': 'arc lint --output simple'}
      \   }
      \ }

" Emmet.
let g:user_emmet_settings = {
\   'html': {
\       'indentation': '  '
\   }
\}

command! -nargs=* SubWord exec "%s/\\<" . expand("<cword>") . "\\>/" . <q-args>

" open NerdTree like Atom's file explorer
noremap <Leader>o :NERDTreeFind<cr>

" select all
nnoremap <Leader>a gg^vG$

" like Cmd-W and Cmd-Q: close current 'tab', quit application
nnoremap <Leader>w :bd<cr>

nnoremap <Leader>b :CtrlPBuffer<cr>

" selecting pasted text.
" from http://vim.wikia.com/wiki/Selecting_your_pasted_text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Turn off highlighting with space
" Press Space to turn off highlighting and clear any message already displayed.
nnoremap <Space> :nohlsearch<Bar>:echo<CR>
