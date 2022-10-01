
" Plugins, using https://github.com/junegunn/vim-plug
call plug#begin('~/.nvimplug')
Plug 'neovim/nvim-lspconfig'            " LSP configuration support
Plug 'mfussenegger/nvim-jdtls'          " Enhanced Java LSP support
Plug 'mfussenegger/nvim-dap'            " Debugger support
Plug 'hrsh7th/nvim-cmp'                 " Auto completion
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'                " Snippets
Plug 'hrsh7th/vim-vsnip-integ'          " Snippets integration
Plug 'srcery-colors/srcery-vim'         " Theme
Plug 'tpope/vim-fugitive'               " Git
Plug 'nvim-lua/popup.nvim'              " For telescope
Plug 'nvim-lua/plenary.nvim'            " For telescope
Plug 'nvim-telescope/telescope.nvim', {'branch': '0.1.x'}  " Fuzzy finder over lists
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' } " Native fzf
Plug 'nvim-treesitter/nvim-treesitter', " Syntax highlight and more
Plug 'simeji/winresizer'                " Resize windows with Ctrl-E
Plug 'nvim-lualine/lualine.nvim'        " Status line
Plug 'mhartington/formatter.nvim'       " Formatting
Plug 'kyazdani42/nvim-web-devicons'     " For looks
Plug '2hdddg/fex.nvim'
Plug '2hdddg/toggleTerm.nvim'
call plug#end()

