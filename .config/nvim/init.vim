" 個人的な基本設定 (vim-sensible の上書き・追加)
set termguicolors " True Color を有効化

set number " 行番号を表示
set relativenumber " 相対行番号を表示
set cursorline " カーソル行をハイライト
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
Plug 'ibhagwan/fzf-lua'
" Plug 'dracula/vim', { 'as': 'dracula' }
" Plug 'vim-airline/vim-airline'
" Plug 'preservim/nerdtree' " File system explorer
" --- LSP & 補完 ---
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
" --- Formatter ---
Plug 'stevearc/conform.nvim'
Plug 'tpope/vim-surround'
Plug 'windwp/nvim-autopairs'
Plug 'kdheepak/lazygit.nvim' " Lazygit integration
Plug 'stevearc/oil.nvim' " File explorer (lightweight)
Plug 'lewis6991/gitsigns.nvim' " Git diff signs in sign column
Plug 'linrongbin16/gitlinker.nvim' " Open GitHub web page for current file
Plug 'sindrets/diffview.nvim' " Git diff and file history viewer

" Svelte support
Plug 'leafOfTree/vim-svelte-plugin'
Plug 'leafgarland/typescript-vim'  " TypeScript syntax support for Svelte
" GitHub Copilot
Plug 'zbirenbaum/copilot.lua' " Copilot補完
Plug 'nvim-lua/plenary.nvim' " 依存ライブラリ
Plug 'CopilotC-Nvim/CopilotChat.nvim' " Copilot対話

call plug#end()

" --- カラースキームを設定 ---
try
  colorscheme github_dark_dimmed
catch /^Vim\%((\a\+)\)\=:E185/
  " Colorscheme not found.
endtry

" fzf-lua のショートカット
nnoremap <leader>f <cmd>FzfLua files<CR>
nnoremap <leader>g <cmd>FzfLua live_grep<CR>
nnoremap <leader>b <cmd>FzfLua buffers<CR>
nnoremap <leader>/ <cmd>FzfLua blines<CR>
nnoremap <leader>: <cmd>FzfLua command_history<CR>

" lazygit のショートカット
nnoremap <leader>lg :LazyGit<CR>

" oil.nvim のショートカット
nnoremap <leader>e :Oil<CR>

" ファイルパスをコピー (yank)
nnoremap <leader>yp :let @+ = expand('%:p')<CR>:echo 'Copied: ' . expand('%:p')<CR>
nnoremap <leader>yr :let @+ = expand('%')<CR>:echo 'Copied: ' . expand('%')<CR>
nnoremap <leader>yn :let @+ = expand('%:t')<CR>:echo 'Copied: ' . expand('%:t')<CR>

" CopilotChat のショートカット
nnoremap <leader>cc :CopilotChatToggle<CR>
vnoremap <leader>ce :CopilotChatExplain<CR>
vnoremap <leader>cr :CopilotChatReview<CR>
vnoremap <leader>cf :CopilotChatFix<CR>
vnoremap <leader>co :CopilotChatOptimize<CR>
nnoremap <leader>cq :CopilotChatReset<CR>

" --- LSP / 補完 / Formatter (Neovim 内蔵 LSP) ---
lua << EOF
-- Mason: 言語サーバー管理
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'ts_ls', 'svelte', 'lua_ls' },
  -- biome: 特定リポでしか使わないので :MasonInstall biome で手動
  -- terraform-ls: brew 経由で導入済み
})

-- nvim-cmp: 補完 UI
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>']      = cmp.mapping.confirm({ select = true }),
    ['<Tab>']     = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item()
      else fallback() end
    end, { 'i', 's' }),
    ['<S-Tab>']   = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item()
      else fallback() end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
})

-- LSP setup (Neovim 0.11+ の新 API: vim.lsp.config / vim.lsp.enable)
-- nvim-lspconfig v2+ は lsp/<server>.lua を自動 discover するので
-- vim.lsp.enable() を呼ぶだけで設定が読み込まれる
local capabilities = require('cmp_nvim_lsp').default_capabilities()
vim.lsp.config('*', { capabilities = capabilities })

-- ts_ls に typescript-svelte-plugin を渡す。
-- これにより .svelte ファイル内のシンボルも ts_ls が認識し、
-- .svelte ファイルからの import / 参照が gr (references) で検出される。
-- coc 時代の coc-svelte 相当の役割。Mason の svelte-language-server に同梱されている。
local svelte_ts_plugin = vim.fn.stdpath('data')
  .. '/mason/packages/svelte-language-server/node_modules/typescript-svelte-plugin'
vim.lsp.config('ts_ls', {
  init_options = {
    plugins = {
      { name = 'typescript-svelte-plugin', location = svelte_ts_plugin },
    },
  },
})

vim.lsp.enable({ 'ts_ls', 'svelte', 'biome', 'lua_ls', 'terraformls' })

-- LSP キーマップ (LspAttach autocmd で buffer-local に貼る)
-- 複数候補が出る系は fzf-lua のピッカー、単発系は内蔵 LSP
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    local fzf  = require('fzf-lua')
    vim.keymap.set('n', 'gd',         fzf.lsp_definitions,         opts)
    vim.keymap.set('n', 'gt',         fzf.lsp_typedefs,            opts)
    vim.keymap.set('n', 'gi',         fzf.lsp_implementations,     opts)
    vim.keymap.set('n', 'gr',         fzf.lsp_references,          opts)
    vim.keymap.set('n', 'K',          vim.lsp.buf.hover,           opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,          opts)
    vim.keymap.set('n', '<leader>ac', fzf.lsp_code_actions,        opts)
    vim.keymap.set('n', '<leader>qf', fzf.lsp_code_actions,        opts)
    vim.keymap.set('n', '[g',         vim.diagnostic.goto_prev,    opts)
    vim.keymap.set('n', ']g',         vim.diagnostic.goto_next,    opts)
  end,
})

-- Format on save (conform.nvim)
-- 各 ft で「あれば biome、なければ prettier」のチェーン
require('conform').setup({
  formatters_by_ft = {
    javascript      = { 'biome', 'prettier', stop_after_first = true },
    typescript      = { 'biome', 'prettier', stop_after_first = true },
    javascriptreact = { 'biome', 'prettier', stop_after_first = true },
    typescriptreact = { 'biome', 'prettier', stop_after_first = true },
    json            = { 'biome', 'prettier', stop_after_first = true },
    css             = { 'prettier' },
    scss            = { 'prettier' },
    html            = { 'prettier' },
    markdown        = { 'prettier' },
    svelte          = { 'prettier' },
  },
  format_on_save = { timeout_ms = 1500, lsp_format = 'fallback' },
})
EOF

" nvim-autopairs の設定
lua << EOF
require('nvim-autopairs').setup{}
EOF

" fzf-lua の設定
lua << EOF
require('fzf-lua').setup({
  -- 'default' はデフォルト (ボトム), 'ivy' は下部スリム, 'fzf-native' は素の fzf 風
  { 'default-title' },
  lsp = {
    -- references は結果が 1 件 (定義自身のみ) の場合でも picker を出す。
    -- jump1=true (デフォルト) だと現在位置にジャンプして「無反応」に見える。
    references = { jump1 = false },
  },
})
EOF

" vim-svelte-plugin の設定
let g:vim_svelte_plugin_load_full_syntax = 1
let g:vim_svelte_plugin_use_typescript = 1

" Terraform: Neovim 0.10+ の組み込み判定 (*.tf→terraform, *.tfvars→terraform-vars) に任せる

" Svelte ファイルタイプの設定
augroup svelte_ft
  autocmd!
  autocmd BufNewFile,BufRead *.svelte set filetype=svelte
  " TypeScript を使用する場合の設定
  autocmd FileType svelte setlocal commentstring=<!--\ %s\ -->
augroup END
" oil.nvim の設定
lua << EOF
require('oil').setup({
  -- デフォルトのファイルエクスプローラーとして使う
  default_file_explorer = true,
  -- カラム設定（アイコン、パーミッションなど）
  columns = {
    "icon",
  },
  -- キーマップ
  keymaps = {
    ["g?"] = "actions.show_help",
    ["<CR>"] = "actions.select",
    ["<C-v>"] = "actions.select_vsplit",
    ["<C-x>"] = "actions.select_split",
    ["<C-t>"] = "actions.select_tab",
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = "actions.close",
    ["<C-r>"] = "actions.refresh",
    ["-"] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["`"] = "actions.cd",
    ["~"] = "actions.tcd",
    ["gs"] = "actions.change_sort",
    ["gx"] = "actions.open_external",
    ["g."] = "actions.toggle_hidden",
  },
  -- 浮動ウィンドウではなく通常のウィンドウで開く
  view_options = {
    show_hidden = false,
  },
})
EOF

" copilot.lua の設定
lua << EOF
require('copilot').setup({
  suggestion = {
    enabled = true,
    auto_trigger = true,
    keymap = {
      accept = "<C-e>",     -- Ctrl+e で補完を受け入れ
      next = "<M-]>",        -- 次の候補
      prev = "<M-[>",        -- 前の候補
      dismiss = "<C-]>",     -- 補完を閉じる
    },
  },
  panel = {
    enabled = true,
    auto_refresh = false,
  },
})
EOF

" CopilotChat の設定
lua << EOF
require('CopilotChat').setup({
  debug = false,
  -- ウィンドウの設定
  window = {
    layout = 'vertical',  -- vertical, horizontal, float
    width = 0.4,          -- ウィンドウ幅（0-1の範囲）
  },
})
EOF

" gitsigns.nvim の設定
lua << EOF
local ok, gitsigns = pcall(require, 'gitsigns')
if ok then
  gitsigns.setup({
    current_line_blame = true, -- 行ごとに誰が書いたか表示
  })
end
EOF

" gitlinker.nvim の設定
lua << EOF
require('gitlinker').setup({
  message = true, -- コピー時にメッセージを表示
})
EOF

" diffview.nvim の設定とキーマッピング
nnoremap <leader>dv :DiffviewOpen<CR>
nnoremap <leader>dc :DiffviewClose<CR>
nnoremap <leader>dh :DiffviewFileHistory<CR>
vnoremap <leader>dh :DiffviewFileHistory<CR>
nnoremap <leader>df :DiffviewFileHistory %<CR>

