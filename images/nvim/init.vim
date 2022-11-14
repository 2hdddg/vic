runtime plugs.vim

"set termguicolors
"colorscheme srcery

lua <<EOF

vim.cmd('colorscheme srcery')

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
vim.o.signcolumn = "auto"
vim.o.clipboard = "unnamed,unnamedplus"
vim.o.gdefault = false -- Otherwise substitution doesn't work multiple times per line
vim.o.cmdheight = 0 -- Gives one more line of core. Requires nvim >= 0.8
vim.o.completeopt = "menu,menuone,noselect" -- As requested by nvim-cmp
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
set_keymap("n", "<leader>n", "<cmd>nohl<cr>", keymap_options)
set_keymap("n", "<leader><SPACE>", "<cmd>lua require('telescope.builtin').git_files()<cr>", keymap_options)
set_keymap("n", "<leader>F", "<cmd>lua require('telescope.builtin').find_files()<cr>", keymap_options)
set_keymap("n", "<leader>b", "<cmd>lua require('telescope.builtin').buffers()<cr>", keymap_options)
set_keymap("n", "<leader>q", "<cmd>lua require('telescope.builtin').quickfix()<cr>", keymap_options)
set_keymap("n", "<leader>g", "<cmd>lua require('telescope.builtin').grep_string()<cr>", keymap_options)
set_keymap("n", "<leader>G", "<cmd>lua require('telescope.builtin').live_grep()<cr>", keymap_options)
set_keymap("n", "<leader>c", "<cmd>lua require('telescope.builtin').git_bcommits()<cr>", keymap_options)
set_keymap("n", "<leader>C", "<cmd>lua require('telescope.builtin').git_commits()<cr>", keymap_options)
set_keymap("n", "<leader>d", "<cmd>Telescope diagnostics bufnr=0<cr>", keymap_options)
set_keymap("n", "<leader>D", "<cmd>Telescope diagnostics<cr>", keymap_options)
set_keymap("n", "<leader>S", "<cmd>Telescope lsp_workspace_symbols<cr>", keymap_options)
set_keymap("n", "<leader>s", "<cmd>Telescope lsp_document_symbols<cr>", keymap_options)
set_keymap("n", "<leader>e", "<cmd>Fex()<cr>", keymap_options)

-- CODE/LSP

-- Syntax highlighting
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,  -- false will disable the whole extension
  },
}

-- Auto completion
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
local cmp = require'cmp'
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


-- Status line
require'statusline'
-- Setup telescope fuzzy finder
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

-- Formatting on save for different languages
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
vim.api.nvim_exec([[
augroup FormatAutogroup
    autocmd!
    autocmd BufWritePost *.java FormatWrite
augroup END
]], true)

-- Nerd font support
require("nvim-web-devicons").setup({})

-- Fex file explorer
require("fex").setup({})

EOF


" Terminal
set shell=/bin/bash

" LSP
" Map all standard LSP commands to ,X
nnoremap ,a <cmd>lua vim.lsp.buf.code_action()<cr>
nnoremap ,d <cmd>lua require('telescope.builtin').lsp_definitions({show_line=false})<CR>
nnoremap ,r <cmd>lua require('telescope.builtin').lsp_references({show_line=false})<CR>
nnoremap ,i <cmd>lua require('telescope.builtin').lsp_implementations({show_line=false})<CR>
nnoremap ,h <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap ,n <cmd>lua vim.lsp.buf.rename()<CR>
" Standard LSP stuff but specific for jdtls plugin
"noremap ,a <Cmd>lua require('jdtls').code_action()<CR>
" noremap ,f <Cmd>lua require('jdtls').code_action(false, 'refactor')<CR>

" DAP debugging
command! Dbr lua require('dap').toggle_breakpoint()
command! Drepl lua require('dap').repl.open()
command! Dstart lua require('dap').continue()
command! Dtest lua require('jdtls').test_nearest_method()
"command! Dn lua require('dap').step_over()
"command! Di lua require('dap').step_into()
"command! Do lua require('dap').step_out()
"command! Dclass lua require('jdtls').test_class()
