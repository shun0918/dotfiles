" 個人的な基本設定 (vim-sensible の上書き・追加)
set number " 行番号を表示
set relativenumber " 相対行番号を表示
set cursorline " カーソル行をハイライト
set cursorcolumn " カーソル列をハイライト
set hlsearch " 検索結果をハイライト
set wildmenu " コマンドの補完メニューを有効化
set showcmd " 入力中のコマンドを表示
set lazyredraw " マクロ実行中の再描画を抑制

" インデント設定
set tabstop=2 " タブの幅を2に設定
set softtabstop=2 " 編集中のタブの幅を2に設定
set shiftwidth=2 " 自動インデントの幅を2に設定
set expandtab " タブをスペースに変換

" 検索設定 (vim-sensibleにないもの)
set ignorecase " 検索時に大文字小文字を区別しない
set smartcase " 検索文字列に大文字が含まれている場合は区別する

" 外観
set t_Co=256 " 256色表示を有効化


" --- Plugin Management ---
" Install vim-plug if not present
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugin settings
call plug#begin('~/.vim/plugged')

" Sensible defaults. Keep this first.
Plug 'tpope/vim-sensible'

" --- カラーテーマ ---
Plug 'cocopon/iceberg.vim'

" Add your plugins here:
" Example plugins (uncomment to use):
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" Plug 'junegunn/fzf.vim'
" Plug 'dracula/vim', { 'as': 'dracula' }
" Plug 'vim-airline/vim-airline'
" Plug 'preservim/nerdtree' " File system explorer
" Plug 'neoclide/coc.nvim', {'branch': 'release'} " Intellisense engine for Vim8 & Neovim

call plug#end()

" --- カラースキームを設定 ---
try
  colorscheme iceberg
catch /^Vim\%((\a\+)\)\=:E185/
  " Colorscheme not found.
endtry
