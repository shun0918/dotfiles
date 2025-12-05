" 個人的な基本設定 (vim-sensible の上書き・追加)
set termguicolors " True Color を有効化

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

" スクロール設定
set scrolloff=8 " カーソルの上下に最低8行の余白を保つ
set sidescrolloff=8 " カーソルの左右に最低8列の余白を保つ

" 外観
set t_Co=256 " 256色表示を有効化

" マウスとクリップボード設定
set mouse=a " マウス操作を有効化
set clipboard=unnamed " ヤンクでシステムクリップボードにコピー
if has('mac')
  set clipboard+=unnamedplus " macOSでシステムクリップボードを使用
endif


" --- Plugin Management ---
" Note: Neovim uses ~/.local/share/nvim/plugged instead of ~/.vim/plugged by default
" We can share plugins by explicitly setting the path, but let's keep them separate for now.
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugin settings
call plug#begin() " For Neovim, we can let it use the default path

" Sensible defaults. Keep this first.
Plug 'tpope/vim-sensible'

" --- カラーテーマ ---
Plug 'projekt0n/github-nvim-theme'

" Add your plugins here:
" Example plugins (uncomment to use):
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Plug 'dracula/vim', { 'as': 'dracula' }
" Plug 'vim-airline/vim-airline'
" Plug 'preservim/nerdtree' " File system explorer
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Intellisense engine for Vim8 & Neovim
Plug 'tpope/vim-surround'
Plug 'windwp/nvim-autopairs'
Plug 'kdheepak/lazygit.nvim' " Lazygit integration

" Svelte support
Plug 'leafOfTree/vim-svelte-plugin'
Plug 'leafgarland/typescript-vim'  " TypeScript syntax support for Svelte

call plug#end()

" --- カラースキームを設定 ---
try
  colorscheme github_dark_dimmed
catch /^Vim\%((\a\+)\)\=:E185/
  " Colorscheme not found.
endtry

" fzf.vim のショートカット
nnoremap <leader>f :Files<CR>
nnoremap <leader>g :Rg<CR>

" lazygit のショートカット
nnoremap <leader>lg :LazyGit<CR>

" coc.nvim のキーマッピング
" <tab> で補完候補を移動 (もし補完がない場合は次の文字を挿入)
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~ '\s'
endfunction

" <CR> (Enter) で補完候補を確定
inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"

" カーソル下の単語のドキュメントを表示 (ノーマルモードでK)
nnoremap <silent> K :call <SNR>coc#util#cursor_word_command('references')<CR>

" 定義へジャンプ (gd)
nnoremap <silent> gd <Plug>(coc-definition)
" 型定義へジャンプ (gt)
nnoremap <silent> gt <Plug>(coc-type-definition)
" 実装へジャンプ (gi)
nnoremap <silent> gi <Plug>(coc-implementation)
" 参照箇所へジャンプ (gr)
nnoremap <silent> gr <Plug>(coc-references)

" nvim-autopairs の設定
lua << EOF
require('nvim-autopairs').setup{}
EOF

" vim-svelte-plugin の設定
let g:vim_svelte_plugin_load_full_syntax = 1
let g:vim_svelte_plugin_use_typescript = 1

" Svelte ファイルタイプの設定
augroup svelte_ft
  autocmd!
  autocmd BufNewFile,BufRead *.svelte set filetype=svelte
  " TypeScript を使用する場合の設定
  autocmd FileType svelte setlocal commentstring=<!--\ %s\ -->
augroup END

