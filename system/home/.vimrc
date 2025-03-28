ilet g:mapleader = " "
inoremap jj <ESC>

" Center search terms with 'n' and 'N'
nnoremap n nzzzv
nnoremap N Nzzzv

" Center half screen jump with <C-d> and <C-u>
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" Paste buffer without storing highlighted text to the buffer
xnoremap <leader>p "_dP

" Edit all instances of the word under the cursor
nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

" Move highlighted text up and down
vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv

" set
set number relativenumber
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab
set smartindent
set nowrap
set nohlsearch
set incsearch
set updatetime=50
set colorcolumn=80
set signcolumn=yes
