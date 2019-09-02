"""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""

set encoding=utf-8          " The encoding displayed
set fileencoding=utf-8      " The encoding written to file
syntax on                   " Enable syntax highlight
set ttyfast                 " Faster redrawing
set lazyredraw              " Only redraw when necessary
set cursorline              " Find the current line quickly.

"""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins List
"""""""""""""""""""""""""""""""""""""""""""""""

call plug#begin()

function! DoRemote(arg)
  UpdateRemotePlugins
endfunction


" nord-vim colorscheme
Plug 'arcticicestudio/nord-vim'

" Bufexplorer
Plug 'jlanzarotta/bufexplorer'

Plug 'bling/vim-airline'

" neomake
" Plug 'neomake/neomake'

" rust support
Plug 'rust-lang/rust.vim'

" Make trailing whitespace be red
Plug 'bronson/vim-trailing-whitespace'

" NERDTree
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

" Async FuzzyFind
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" .editorconfig
Plug 'editorconfig/editorconfig-vim'

" semantic-based completion
Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }

" linting engine
Plug 'w0rp/ale'

" Handle comments
Plug 'tomtom/tcomment_vim'

" Syntastic
Plug 'vim-syntastic/syntastic'

" LanguageClient
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" OrgMode
Plug 'jceb/vim-orgmode'

" Ansible
Plug 'chase/vim-ansible-yaml'

" Terraform
Plug 'hashivim/vim-terraform'


" LanguageClient-Neovim setup
let g:LanguageClient_autoStart = 1
let g:LanguageClient_loadSettings = 1
let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_serverCommands = {
    \ 'python': ['pyls'],
    \ 'rust': ['rls'],
    \ 'php': ['php', '~/.tooling/php-language-server/bin/php-language-server.php'],
    \ 'sh': ['bash-language-sever', 'start'],
    \ 'c': ['ccls', '--log-file=/tmp/cc.log'],
    \ 'cpp': ['ccls', '--log-file=/tmp/cc.log'],
    \ 'cuda': ['ccls', '--log-file=/tmp/cc.log'],
    \ 'objc': ['ccls', '--log-file=/tmp/cc.log'],
    \ 'javascript': ['~/source/javascript-typescript-langserver/lib/language-server-stdio'],
    \ 'go': ['go-langserver'],
    \ }

noremap <leader>h  :call LanguageClient#textDocument_hover()<CR>
noremap <leader>gd :call LanguageClient#textDocument_definition()<CR>
noremap <leader>gi :call LanguageClient#textDocument_implementation()<CR>
noremap <leader>rn :call LanguageClient#textDocument_rename()<CR>
noremap <leader>r  :call LanguageClient#textDocument_references()<CR>

" Ale config
let g:ale_rust_rls_toolchain = "stable"
let g:ale_linters = {
            \ 'python': ['pylint', 'pyls'],
            \ 'rust': ['cargo'],
            \ 'php': ['langserver', 'php_cs_fixer'],
            \ 'bash': ['shellcheck'],
            \ }

let g:ale_fix_on_save = 1
let g:ale_fixers = {
            \ 'rust': ['rustfmt'],
            \ 'php': ['php_cs_fixer'],
            \ 'bash': ['shfmt'],
            \ }

" Vim-fugitive
Plug 'tpope/vim-fugitive'

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""
" => Plugin Related Configs
"""""""""""""""""""""""""""""""""""""""""""""""
" airline
set laststatus=2
let g:airline_left_sep=""
let g:airline_left_alt_sep="|"
let g:airline_right_sep=""
let g:airline_right_alt_sep="|"
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#tab_nr_type = 1 " show tab number not number of split panes
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#hunks#enabled = 0
let g:airline_section_z = ""

" Rust
let g:rustfmt_autosave = 1

" NERDTree
map <silent> <LocalLeader>nt :NERDTreeToggle<CR>
map <silent> <LocalLeader>nr :NERDTree<CR>
map <silent> <LocalLeader>nf :NERDTreeFind<CR>

" close NERDTree after a file is opened
let g:NERDTreeQuitOnOpen=1

" deoplete
let g:deoplete#enable_at_startup=1
inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<C-i>"

" fix files on save
let g:ale_fix_on_save = 1

" lint after 1000ms after changes are made both on insert mode and normal mode
let g:ale_lint_on_text_changed = 'always'
let g:ale_lint_delay = 1000

" use emojis for errors and warnings
" let g:ale_sign_error = '✗\ '
" let g:ale_sign_warning = '⚠\ '

" fixer configurations
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\}

" make FZF respect gitignore if `ag` is installed
if (executable('ag'))
    let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
endif

" Syntastic
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" vim-terraform
let g:terraform_fmt_on_save = 1


"""""""""""""""""""""""""""""""""""""""""""""""
" => Visual Related Configs
"""""""""""""""""""""""""""""""""""""""""""""""

" 256 colors
set t_Co=256

" set colorscheme
silent! colorscheme nord

" long lines as just one line (have to scroll horizontally)
set wrap
set textwidth=0

" keep 5 lines of context when scrolling
set scrolloff=5

" line numbers
" set relativenumber
set number

" Show ruler
set ruler

" show the status line all the time
set laststatus=2

" disable scrollbars (real hackers don't use scrollbars)
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L

"""""""""""""""""""""""""""""""""""""""""""""""
" => Keymappings
"""""""""""""""""""""""""""""""""""""""""""""""

" copy and paste to/from vIM and the clipboard
nnoremap <C-y> +y
vnoremap <C-y> +y
nnoremap <C-p> +P
vnoremap <C-p> +P

" access system clipboard
set clipboard=unnamed

" swapfiles location
set backupdir=/tmp//
set directory=/tmp//

" fzf
set rtp+=~/.fzf
map <silent> <LocalLeader>ff :FZF<CR>

" TComment
map <silent> <LocalLeader>cc :TComment<CR>
map <silent> <LocalLeader>uc :TComment<CR>

"""""""""""""""""""""""""""""""""""""""""""""""
" => Indentation
"""""""""""""""""""""""""""""""""""""""""""""""

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
" :help smarttab
set smarttab

" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2
set softtabstop=2

" Auto indent
" Copy the indentation from the previous line when starting a new line
set ai

" Smart indent
" Automatically inserts one extra level of indentation in some cases, and works for C-like files
set si
