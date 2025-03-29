" === DEVGRU .vimrc – clean & pro ===

" 🔹 Kolor i styl
syntax on
set background=dark
colorscheme desert     " możesz zmienić na elflord, ron, torte itd.

" 🔹 Widoczność i komfort
set number             " numeracja linii
set relativenumber     " względna numeracja
set cursorline         " podświetlenie linii
set showcmd            " pokazuj polecenia
set showmode           " tryb INSERT/REPLACE itd.
set ruler              " pokazuj pozycję kursora

" 🔹 Taby i wcięcia
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab          " spacje zamiast tabów
set autoindent
set smartindent
filetype plugin indent on

" 🔹 Wyszukiwanie
set ignorecase
set smartcase
set incsearch
set hlsearch

" 🔹 Clipboard (jeśli masz +clipboard)
" set clipboard=unnamedplus

" 🔹 Inne
set scrolloff=5        " zawsze 5 linii wokół kursora
set wrap               " zawijaj długie linie
set linebreak          " zawijaj na słowach
set wildmenu           " lepsze autouzupełnianie
set nobackup
set nowritebackup
set noswapfile

" 🔹 Klawisze jak w edytorze
noremap <C-s> :w<CR>
noremap <C-q> :q<CR>
inoremap <C-s> <Esc>:w<CR>i
inoremap <C-q> <Esc>:q<CR>

" 🔹 Pasek statusu
set laststatus=2
set statusline=%F%m%r%h%w\ [%{&ff}]\ [%Y]\ [line:%l/%L]\ [col:%c]

" 🔹 Znaki niewidzialne (opcjonalnie)
" set list listchars=tab:»·,trail:·,nbsp:␣

" 🔹 Wyłącz dzwonki
set noerrorbells
set visualbell