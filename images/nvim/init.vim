set number
set hidden
set wildchar=<Tab> wildmenu wildmode=full
syntax on
set splitright
set splitbelow
set list listchars=tab:»·,trail:·,extends:#
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set cursorline
set colorcolumn=80
set nowrap
set nomodeline
set noswapfile
" Use simple/system clipboard
set clipboard+=unnamedplus
set signcolumn=yes
" Skip banner on top of netrw
let g:netrw_banner=0
" Otherwise substitution doesn't work multiple times per line
set nogdefault
" Gives one more line of code. Requires nvim >= 0.8
set cmdheight=0

nnoremap <SPACE> <Nop>
let mapleader = " "

" set shada='50,%,n/host/workspace/nvim.shada

" jk is escape
inoremap jk <esc>

runtime plugs.vim

set termguicolors
colorscheme srcery

" Terminal
nnoremap <silent> <C-z> <cmd>lua require("toggleTerm").toggle()<cr>
tnoremap <silent> <C-z> <cmd>lua require("toggleTerm").toggle()<cr>

set completeopt=menu,menuone,noselect

lua <<EOF

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


" Leader keys
nnoremap <leader>n <cmd>nohl<cr> " No hightlight
nnoremap <leader><SPACE> <cmd>lua require('telescope.builtin').git_files()<cr>
nnoremap <leader>F <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>b <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>q <cmd>lua require('telescope.builtin').quickfix()<cr>
nnoremap <leader>g <cmd>lua require('telescope.builtin').grep_string()<cr>
nnoremap <leader>G <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>c <cmd>lua require('telescope.builtin').git_bcommits()<cr>
nnoremap <leader>C <cmd>lua require('telescope.builtin').git_commits()<cr>
nnoremap <leader>d <cmd>Telescope diagnostics bufnr=0<CR>
nnoremap <leader>D <cmd>Telescope diagnostics<CR>
nnoremap <leader>S <cmd>Telescope lsp_workspace_symbols<CR>
nnoremap <leader>s <cmd>Telescope lsp_document_symbols<CR>
nnoremap <leader>e <cmd>Fex()<cr>

" Terminal
tnoremap jk  <C-\><C-n>
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
