-- Options
vim.o.number = true
vim.o.hidden = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.cursorline = true
vim.o.cursorcolumn = true
vim.o.colorcolumn = 80
vim.o.wrap = false
vim.o.modeline = false
vim.o.swapfile = false
vim.o.signcolumn = "auto:3"
vim.o.clipboard = "unnamed,unnamedplus"
vim.o.gdefault = false -- Otherwise substitution doesn't work multiple times per line
vim.o.cmdheight = 0 -- Gives one more line of core. Requires nvim >= 0.8
vim.o.completeopt = "menu,menuone,noselect" -- As requested by nvim-cmp
vim.o.relativenumber = true
vim.opt.termguicolors = true
vim.opt.listchars = { tab = "»·", trail = "·", extends="#"}
vim.opt.list = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 0
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.showmatch = true -- Highlight matching brackets
vim.opt.matchtime = 1
vim.g.netrw_banner = 0

-- Set leader before any plugins
vim.g.mapleader = " "

local plugins = {
    -- LSP configuration support
    'neovim/nvim-lspconfig',
    -- Enhanced Java LSP support
    'mfussenegger/nvim-jdtls',
    -- Debugger support
    'mfussenegger/nvim-dap',
    -- Auto completion
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    -- Snippets
    'hrsh7th/vim-vsnip',
    'hrsh7th/vim-vsnip-integ',
    'hrsh7th/nvim-cmp',
    -- Color theme
    'srcery-colors/srcery-vim',
    -- Git
    'tpope/vim-fugitive',
    -- For telescope
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    -- Native fzf
    { 'nvim-telescope/telescope-fzf-native.nvim', run = "make" },
    -- Fuzzy finder over lists
    { 'nvim-telescope/telescope.nvim', branch = '0.1.x'  },
    -- Syntax highlight and more
    { 'nvim-treesitter/nvim-treesitter' }, --run = function() vim.cmd("TSUpdate") end },
    -- Resize windows with Ctrl-E
    'simeji/winresizer',
    -- Status line
    'nvim-lualine/lualine.nvim',
    -- Formatting
    'mhartington/formatter.nvim',
    -- For looks
    'kyazdani42/nvim-web-devicons',
    -- For marks in gutter
    'chentoast/marks.nvim',
    -- File explorer
    '2hdddg/fex.nvim',
    -- Toggle terminal
    '2hdddg/toggleTerm.nvim'
}

-- Bootstrap plugin manager
local ensure_paq = function()
    local path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
    if vim.fn.empty(vim.fn.glob(path)) > 0 then
        vim.fn.system { 'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', path }
        vim.cmd [[packadd paq-nvim]]
        return true
    end
    return false
end
local install_plugins = ensure_paq()
local paq = require('paq')
paq(plugins)
if install_plugins then
    paq.install()
    -- Wait for install to complete before proceeding to quit
    vim.cmd('autocmd User PaqDoneInstall quit')
    -- Can not continue to setup plugins here since they are being installed async
    return
end

local border = {
      { "╭" },
      { "─"},
      { "╮"},
      { "│"},
      { "╯"},
      { "─"},
      { "╰"},
      { "│"},
}
local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = {
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<CR>'] = cmp.mapping.confirm({select = true}),
          ['<C-e>'] = cmp.mapping {
              i = cmp.mapping.abort(),
              c = cmp.mapping.close(),
          },
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp'},
        { name = 'vsnip'},
        { name = 'nvim_lsp_signature_help'},
    }, {
        { name = 'buffer' },
        { name = 'path' },
    }),
    window = {
        completion = {
            border = border,
        },
        documentation = {
            border = border,
        },
  },
})

vim.cmd('colorscheme srcery')

require('statusline')

require("marks").setup({})

local telescope = require'telescope'
telescope.setup{
  defaults = {
    layout_strategy = 'bottom_pane',
    sorting_strategy = "ascending",
    wrap_results = true,
    vimgrep_arguments = { 'ag', '--vimgrep' },
  },
}
telescope.load_extension('fzf')

require("formatter").setup({
        filetype = {
            -- Forward actual formatting to script in workspace
            java = {
                function()
                    return {
                        exe = "/host/workspace/format",
                        args = { "-" },
                        stdin = true,
                    }
                end
            }
        }
    })


-- ==========================
-- Keymaps
-- ==========================
local keymap_options = { noremap = true, silent = true }
local set_keymap = vim.api.nvim_set_keymap
-- UNCATEGORIZED
-- jk is escape from insert
set_keymap("i", "jk", "<esc>", keymap_options)
set_keymap("t", "jk", "<C-\\><C-n>", keymap_options)
-- Disable space in normal mode as long as it is the leader
set_keymap("n", "<space>", "<nop>", keymap_options)
-- Toggle to terminal from normal mode and back again
set_keymap("n", "<C-z>", "<cmd>lua require('toggleTerm').toggle()<cr>", keymap_options)
set_keymap("t", "<C-z>", "<cmd>lua require('toggleTerm').toggle()<cr>", keymap_options)
-- LEADER
set_keymap("n", "<leader>n", "<cmd>nohl<cr>", keymap_options)                                                   -- Clear highlight
set_keymap("n", "<leader><SPACE>", "<cmd>lua require('telescope.builtin').git_files()<cr>", keymap_options)     -- Fuzzy find among git files
set_keymap("n", "<leader>F", "<cmd>lua require('telescope.builtin').find_files()<cr>", keymap_options)          -- Fuzzy find among all files
set_keymap("n", "<leader>b", "<cmd>lua require('telescope.builtin').buffers()<cr>", keymap_options)             -- List of buffers
set_keymap("n", "<leader>q", "<cmd>lua require('telescope.builtin').quickfix()<cr>", keymap_options)            -- List of quick fixes
set_keymap("n", "<leader>g", "<cmd>lua require('telescope.builtin').grep_string()<cr>", keymap_options)         -- Grep under cursor
set_keymap("n", "<leader>G", "<cmd>lua require('telescope.builtin').live_grep()<cr>", keymap_options)           -- Live grep
set_keymap("n", "<leader>c", "<cmd>lua require('telescope.builtin').git_bcommits()<cr>", keymap_options)
set_keymap("n", "<leader>C", "<cmd>lua require('telescope.builtin').git_commits()<cr>", keymap_options)
set_keymap("n", "<leader>d", "<cmd>Telescope diagnostics bufnr=0<cr>", keymap_options)                          -- Show diagnostics for current buffer
set_keymap("n", "<leader>D", "<cmd>Telescope diagnostics<cr>", keymap_options)                                  -- Show all diagnostics
set_keymap("n", "<leader>S", "<cmd>Telescope lsp_workspace_symbols<cr>", keymap_options)
set_keymap("n", "<leader>s", "<cmd>Telescope lsp_document_symbols<cr>", keymap_options)
set_keymap("n", "<leader>e", "<cmd>Fex()<cr>", keymap_options)
set_keymap("n", "<leader>m", "<cmd>MarksQFListAll<cr>", keymap_options)
set_keymap("n", "<leader>1", "<cmd>lua vim.o.relativenumber = not vim.o.relativenumber<cr>", keymap_options)
-- COMMA
set_keymap("n", ",a", "<cmd>lua vim.lsp.buf.code_action()<cr>", keymap_options)
set_keymap("n", ",d", "<cmd>lua require('telescope.builtin').lsp_definitions({show_line=false})<CR>", keymap_options)
set_keymap("n", ",r", "<cmd>lua require('telescope.builtin').lsp_references({show_line=false})<CR>", keymap_options)
set_keymap("n", ",i", "<cmd>lua require('telescope.builtin').lsp_implementations({show_line=false})<CR>", keymap_options)
set_keymap("n", ",h", "<cmd>lua vim.lsp.buf.hover()<CR>", keymap_options)
set_keymap("n", ",n", "<cmd>lua vim.lsp.buf.rename()<CR>", keymap_options)

-- Formatting on save for different languages
vim.api.nvim_exec([[
augroup FormatAutogroup
    autocmd!
    autocmd BufWritePost *.java FormatWrite
augroup END
]], true)

-- Debugger commands (just a bit shorter than dap versions)
vim.api.nvim_create_user_command("Dbr",
    function(opts)
        require('dap').toggle_breakpoint()
    end, {})
vim.api.nvim_create_user_command("Dstart",
    function(opts)
        require('dap').continue()
    end, {})
vim.api.nvim_create_user_command("Drepl",
    function(opts)
        require('dap').repl.open()
    end, {})