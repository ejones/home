" make changes to *this* file live
if !exists("g:did_liven_vimrc")
    let g:did_liven_vimrc=1
    au BufWritePost .vimrc so %
endif

" standard editor setup
set ai ml mls=5 et sts=4 ts=4 sw=4 ls=2 bs=2 
  \ stl=%t\ %y\ %r\ %m\ %{fugitive#statusline()}%=%c,%l/%L
  \ nu hid lazyredraw autoread
  \ previewheight=20
filetype on
filetype plugin on
syntax on

" switch dir on BufEnter
au BufEnter * silent! lcd %:p:h

" Git
so $HOME/.vim/plugin/fugitive.vim

set bg=dark

" Colors - Solarized
if has('gui_running')
    so $HOME/.vim/autoload/togglebg.vim
    colors solarized

    " Need high contrast for light mode Solarized
    function! AdjustSolarizedContrast()
        let act = g:solarized_contrast
        let expect = &bg == 'dark' ? 'low' : 'high'
        if act != expect
            let g:solarized_contrast = expect
            colors solarized
        endif
    endfunction

    call AdjustSolarizedContrast()
    au! ColorScheme * call AdjustSolarizedContrast()
endif

" good ol' MacVim
if has("mac")
    set macmeta
endif

" smaller indent for markup and cs
au! FileType \(xml\|html\|soy\|coffee\) setlocal sw=2 sts=2

" cindent for C-like languages
au! FileType \(cs\|cpp\|c\|java\) setlocal cindent

" cindent can't quite handle JS
au! FileType javascript setlocal smartindent

" html has some long lines man
" json does not support line breaks in strings so by definition there may be
" really long lines
au! FileType \(html\|json\) setlocal nowrap

" Complete curlies
inoremap {<CR> {<CR>}<C-o>O
inoremap {<Space> {

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

command! ScratchWithPrompt
\  if expand("%") != "*scratch*"
\|   Scratch
\| endif
\| exec "normal Go".g:lastdir." ".expand("$USER")."$ "

command! -bang -nargs=* -complete=file ScratchEnterPrompt
\  let g:lastcommand="<args>"
\| exec "normal o".g:lastcommand."<esc>kJ"
\| exec "r! ".g:lastcommand
\| normal o


" Neocomplcache
let g:neocomplcache_enable_at_startup = 1
imap <C-k> <Plug>(neocomplcache_snippets_expand)
smap <C-k> <Plug>(neocomplcache_snippets_expand)

" NERDTREE
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1

" Conque Shell
let g:ConqueTerm_EscKey = '<C-q>'
let g:ConqueTerm_ReadUnfocused = 1

" between MacVim and Conque, Meta seems to be mostly clobbered. This encodes
" the most needed meta readline bindings
"function! ConqueSendMeta(key)
"    call conque_term#get_instance().write("".a:key)
"endfunction

"function! ConqueStartup(term)
"    for key in split(" b f <BS> d ")
"        if key[0] == "<"
"            let mapkey = key[1:-2]
"        else
"            let mapkey = key
"        endif
"        exec "inoremap <buffer> <M-".mapkey."> <C-o>:call ConqueSendMeta('".key."')<cr>"
"    endfor
"endfunction

"call conque_term#register_function('after_startup', 'ConqueStartup')

command! -nargs=* SubWord exec "%s/\\<" . expand("<cword>") . "\\>/" . <q-args>

" Shift + Tab
inoremap <S-Tab> <C-o><<

" UNIX copy / paste
command! -range Copy silent! <line1>,<line2>w ! pbcopy
command! -range Paste silent! <line1>,<line2>r ! pbpaste
command! -range PasteReplace exec <line1>.",".<line2>."Paste" | normal gvD

" Meta mappings of the commonest ex commands, using their rough GUI/Web
" Browser equivalents
vnoremap <M-c> :Copy<cr>
nnoremap <M-c> :Copy<cr>
vnoremap <M-x> :Copy<cr>gvD
nnoremap <M-x> :Copy<cr>dd
vnoremap <M-v> :PasteReplace<cr>
nnoremap <M-v> :Paste<cr>

" cycle windows
nnoremap <M-`> :bn<cr>
nnoremap <M-~> :bp<cr>

" [o]pen file
map <M-o> :NERDTree %:p:h<cr>

" [n]ew window - use :edit because you never start in a truly blank window in
" vi (even if you're making a new file, you give it a name first)
nnoremap <M-n> :edit %:p:h/

" [1]un command -- opens/switches to a scratch buffer and enters ex for an OS
" command
"nnoremap <M-1> :ScratchWithPrompt<cr>:redraw<cr>:ScratchEnterPrompt!
nnoremap <M-r> :ConqueTerm bash -login<cr>

" select [a]ll
nnoremap <M-a> gg^vG$

" [s]ave file, [S]ave all
nnoremap <M-s> :write<cr>
nnoremap <M-S> :wall<cr>

" like Cmd-W and Cmd-Q: close current 'tab', quit application
nnoremap <M-w> :bd<cr>
nnoremap <M-q> :qall<cr>

" switch to named window, based on screen's similar mapping
nnoremap <M-'> :ls<cr>:b

" selecting pasted text.
" from http://vim.wikia.com/wiki/Selecting_your_pasted_text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" like Eclipse's ctrl-arrow to move whole lines up and down
nnoremap <M-j> ddkP
vnoremap <M-j> DkP
nnoremap <M-k> ddp
vnoremap <M-k> Dp
