
" Plugins, using https://github.com/junegunn/vim-plug
call plug#begin('~/.nvimplug')
Plug 'neovim/nvim-lspconfig'         " LSP configuration support
Plug 'mfussenegger/nvim-jdtls'       " Enhanced Java LSP support
Plug 'mfussenegger/nvim-dap'         " Debugger support
Plug 'hrsh7th/nvim-compe'            " Auto completion
Plug 'srcery-colors/srcery-vim'      " Theme
Plug 'tpope/vim-fugitive'            " Git
Plug 'nvim-lua/popup.nvim'           " For telescope
Plug 'nvim-lua/plenary.nvim'         " For telescope
Plug 'nvim-telescope/telescope.nvim' " Fuzzy finder over lists
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " neovim 0.5 syntax highlighter experiment
Plug 'simeji/winresizer'             " Resize windows with Ctrl-E
"Plug 'hoob3rt/lualine.nvim'         " Status line
Plug 'shadmansaleh/lualine.nvim'     " Fork of status line, will be merged to main?
call plug#end()

