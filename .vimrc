" make changes to *this* file live
if !exists("g:did_liven_vimrc")
    let g:did_liven_vimrc=1
    au BufWritePost .vimrc so %
endif

" standard editor setup
set ai ml mls=5 et sts=4 ts=4 sw=4 ls=2 bs=2 
  \ stl=%t\ %y\ %r\ %m\ %=%c,%l/%L nu hid lazyredraw bg=dark
filetype on
filetype plugin on
syntax on

" smaller indent for markup and cs
au FileType \(xml\|html\|soy\|coffee\) setlocal sw=2 sts=2

" cindent for C-like languages
au FileType \(cs\|cpp\|c\|java\) setlocal cindent

" cindent can't quite handle JS
au FileType javascript setlocal smartindent

" html has some long lines man
" json does not support line breaks in strings so by definition there may be
" really long lines
au FileType \(html\|json\) setlocal nowrap

" Scratch
au BufNewFile \*scratch\* setlocal bt=nofile bh=hide noswf bl
command! Scratch e \*scratch\*

" Neocomplcache
let g:neocomplcache_enable_at_startup = 1
imap <C-k> <Plug>(neocomplcache_snippets_expand)
smap <C-k> <Plug>(neocomplcache_snippets_expand)

command! -nargs=* SubWord exec "%s/\\<" . expand("<cword>") . "\\>/" . <q-args>

" UNIX copy / paste
command! -range Copy silent! <line1>,<line2>w ! pbcopy
command! -range Paste silent! <line1>,<line2>r ! pbpaste
command! -range PasteReplace exec <line1>.",".<line2>."Paste" | normal gvD

" Meta mappings of the commonest ex commands, using their rough GUI/Web
" Browser equivalents
vnoremap c :Copy<cr>
nnoremap c :Copy<cr>
vnoremap x :Copy<cr>gvD
nnoremap x :Copy<cr>dd
vnoremap v :PasteReplace<cr>
nnoremap v :Paste<cr>

" cycle windows
nnoremap ` :bn<cr>
nnoremap ~ :bp<cr>

" [o]pen file
nnoremap o :edit %:p:h<cr>

" [n]ew window - use :edit because you never start in a truly blank window in
" vi (even if you're making a new file, you give it a name first)
nnoremap n :edit %:p:h/


" select [a]ll
nnoremap a gg^vG$


" [s]ave file, [S]ave all
nnoremap s :write<cr>
nnoremap S :wall<cr>

" like Cmd-W and Cmd-Q: close current 'tab', quit application
nnoremap w :bd<cr>
nnoremap q :qall<cr>

" selecting pasted text.
" from http://vim.wikia.com/wiki/Selecting_your_pasted_text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" like Eclipse's ctrl-arrow to move whole lines up and down
nnoremap <up> ddkP
vnoremap <up> DkP
nnoremap <down> ddp
vnoremap <down> Dp
