set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

Plugin 'vividchalk.vim'
Plugin 'fcitx.vim'
Plugin 'taglist.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'altercation/vim-colors-solarized'
Plugin 'jonathanfilip/vim-lucius'
Plugin 'Indent-Guides'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required.

set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set number

colorscheme desert

"Indent Guid
let g:indent_guides_auto_colors = 0
au FileType * :IndentGuidesEnable
au FileType * hi IndentGuidesOdd  guibg=red   ctermbg=4
au FileType * hi IndentGuidesEven guibg=green ctermbg=3
let g:indent_guides_guide_size = 1

"YCM
let g:ycm_min_num_of_chars_for_completion = 1

"Tab
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent

syntax on
filetype plugin indent on
filetype plugin on


"Some Key Bind

"C-q to quit
"inoremap <C-q> <Esc>:q<CR>
"nnoremap <C-q> :q<CR>
"vnoremap <C-q> <Esc>:q<CR>

"C-s to save
"inoremap <C-s> <Esc>:w<CR>
"nnoremap <C-s> :w<CR>
"vnoremap <C-s> <Esc>:w<CR>

map <C-c> <Esc>
