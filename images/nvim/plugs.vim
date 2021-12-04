
" Plugins, using https://github.com/junegunn/vim-plug
call plug#begin('~/.nvimplug')
Plug 'neovim/nvim-lspconfig'            " LSP configuration support
Plug 'mfussenegger/nvim-jdtls'          " Enhanced Java LSP support
Plug 'mfussenegger/nvim-dap'            " Debugger support
Plug 'hrsh7th/nvim-compe'               " Auto completion
Plug 'srcery-colors/srcery-vim'         " Theme
Plug 'tpope/vim-fugitive'               " Git
Plug 'nvim-lua/popup.nvim'              " For telescope
Plug 'nvim-lua/plenary.nvim'            " For telescope
Plug 'nvim-telescope/telescope.nvim'    " Fuzzy finder over lists
Plug 'nvim-treesitter/nvim-treesitter', " Syntax highlight and more
Plug 'simeji/winresizer'                " Resize windows with Ctrl-E
Plug 'nvim-lualine/lualine.nvim'        " Status line
call plug#end()

