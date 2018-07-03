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
filetype on
filetype indent plugin on
syntax on

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

" good ol' MacVim
if has("mac") && has("gui_running")
    set macmeta
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

" Complete curlies
" inoremap { {}<C-O>i
" inoremap {<CR> {<CR>}<C-O>O<Tab>
" inoremap ( ()<C-O>i
" inoremap (<CR> (<CR>)<C-O>O<Tab>
" inoremap [ []<C-O>i
" inoremap [<CR> [<CR>]<C-O>O<Tab>

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

command! ScratchWithPrompt
\  if expand("%") !=# "*scratch*"
\|   Scratch
\| endif
\| exec "normal Go".g:lastdir." ".expand("$USER")."$ "

command! -bang -nargs=* -complete=file ScratchEnterPrompt
\  let g:lastcommand="<args>"
\| exec "normal o".g:lastcommand."<esc>kJ"
\| exec "r! ".g:lastcommand
\| normal o

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


" Run script and paste output at bottom of file (expects there to be a
" commented-out section)
" function! RunFile()
"     write
"     normal Go
"     let l:res = []
"     for s in split(system(expand("%:p")), "\n")
"         call add(l:res, printf(&cms, " ".s))
"     endfor
"     call append(line('$'), l:res)
"     normal G
" endfunction

nnoremap <D-r> :w \| make<CR>
inoremap <D-r> <Esc>:w \| make<CR>

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

" RipGrep
let g:rg_highlight = 1
let g:rg_derive_root = 1

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

" Emmet.
let g:user_emmet_settings = {
\   'html': {
\       'indentation': '  '
\   }
\}

command! -nargs=* SubWord exec "%s/\\<" . expand("<cword>") . "\\>/" . <q-args>

command! -nargs=1 Linkify exec "s," . expand("<cfile>") . ",<a href=\"" . <q-args> . "\\0\">\\0</a>,g"

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
nnoremap <M-[> :bn<cr>
nnoremap <M-]> :bp<cr>

" [o]pen file
noremap <M-o> :NERDTree %:p:h<cr>

" open NerdTree like Atom's file explorer
noremap <M-\> :NERDTreeFind<cr>

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
nnoremap <M-'> :CtrlPBuffer<cr>

" selecting pasted text.
" from http://vim.wikia.com/wiki/Selecting_your_pasted_text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" like Eclipse's ctrl-arrow to move whole lines up and down
nnoremap <M-k> ddkP
vnoremap <M-k> DkP
nnoremap <M-j> ddp
vnoremap <M-j> Dp

" Turn off highlighting with space
" Press Space to turn off highlighting and clear any message already displayed.
nnoremap <Space> :nohlsearch<Bar>:echo<CR>
