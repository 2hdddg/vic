set number
set hidden
set wildchar=<Tab> wildmenu wildmode=full
syntax on
set splitright
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

let mapleader = ";"

" set shada='50,%,n/host/workspace/nvim.shada

" jk is escape
inoremap jk <esc>

runtime plugs.vim
runtime terminal.vim

set termguicolors
colorscheme srcery

" Terminal
nnoremap <silent> <C-z> :call terminal#toggle()<Enter>
tnoremap <silent> <C-z> :call terminal#toggle()<Enter>

set completeopt=menu,menuone,noselect
" One global status line, more room for filename
set laststatus=3

lua <<EOF

-- Syntax highlighting
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,  -- false will disable the whole extension
  },
}

-- Auto completion
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
        {},
    }, {
        { name = 'buffer' },
        { name = 'path' },
    }),
})

-- Status line
local function classInStatusLine()
    return require('nvim-treesitter').statusline({type_patterns={"class"},indicator_size=50})
end
local colors = {
  black        = vim.g.srcery_black,
  white        = vim.g.srcery_bright_white,
  red          = vim.g.srcery_red,
  green        = vim.g.srcery_green,
  blue         = vim.g.srcery_blue,
  yellow       = vim.g.srcery_yellow,
  orange       = vim.g.srcery_bright_orange,
  gray         = vim.g.srcery_xgray3,
  darkgray     = vim.g.srcery_xgray1,
  lightgray    = vim.g.srcery_xgray6,
}
local theme = {
  normal = {
    a = {bg = colors.green, fg = colors.black, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.white},
    c = {bg = colors.lightgray, fg = colors.darkgray},
    x = {bg = colors.black, fg = colors.black},
    y = {bg = colors.orange, fg = colors.black},
    z = {bg = colors.orange, fg = colors.black},
  },
  insert = {
    a = {bg = colors.blue, fg = colors.black, gui = 'bold'},
  },
  visual = {
    a = {bg = colors.yellow, fg = colors.black, gui = 'bold'},
  },
  replace = {
    a = {bg = colors.red, fg = colors.black, gui = 'bold'},
  },
  command = {
    a = {bg = colors.gray, fg = colors.black, gui = 'bold'},
  },
  inactive = {
    a = {bg = colors.darkgray, fg = colors.gray},
    b = {bg = colors.lightgray, fg = colors.white},
    c = {bg = colors.lightgray, fg = colors.darkgray},
    x = {bg = colors.darkgray, fg = colors.lightgray},
    y = {bg = colors.darkgray, fg = colors.lightgray},
    z = {bg = colors.darkgray, fg = colors.lightgray},
  }
}
require'lualine'.setup {
  options = {
    icons_enabled = false,
    theme = theme,
    component_separators = {'', ''},
    section_separators = {'', ''},
    disabled_filetypes = {'class'}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'filename'},
    lualine_c = {classInStatusLine},
    lualine_x = {{'diagnostics', sources = {'nvim_diagnostic'}}},
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {'filename'},
    lualine_c = {classInStatusLine},
    lualine_x = {},
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
  tabline = {},
  extensions = {}
}

-- Setup telescope fuzzy finder
local telescope = require'telescope'
local previewers = require'telescope.previewers'
telescope.setup{
  defaults = {
    layout_strategy = 'vertical',
    layout_config = {
        vertical = { width = 0.9 },
    },
    vimgrep_arguments = { 'ag', '--vimgrep' },
    cache_picker = {
        num_pickers = 10,
    },
  },
  pickers = {},
}
telescope.load_extension('fzf')

-- Formatting on save for different languages
require("formatter").setup(
    {
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

EOF


" Leader keys
nnoremap <leader>n <cmd>nohl<cr> " No hightlight
nnoremap <leader>f <cmd>lua require('telescope.builtin').git_files()<cr>
nnoremap <leader>F <cmd>lua require('telescope.builtin').file_browser()<cr>
nnoremap <leader>b <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>q <cmd>lua require('telescope.builtin').quickfix()<cr>
nnoremap <leader>g <cmd>lua require('telescope.builtin').grep_string()<cr>
nnoremap <leader>G <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>c <cmd>lua require('telescope.builtin').git_bcommits()<cr>
nnoremap <leader>C <cmd>lua require('telescope.builtin').git_commits()<cr>

" Terminal
tnoremap jk  <C-\><C-n>
set shell=/bin/bash

" LSP
" Map all standard LSP commands to ,X
nnoremap ,a <cmd>lua vim.lsp.buf.code_action()<cr>
nnoremap ,d <cmd>lua require('telescope.builtin').lsp_definitions({shorten_path = false})<CR>
nnoremap ,r <cmd>lua require('telescope.builtin').lsp_references({shorten_path = false})<CR>
nnoremap ,D <cmd>Telescope diagnostics bufnr=0<CR>
nnoremap ,W <cmd>Telescope diagnostics<CR>
nnoremap ,i <cmd>lua require('telescope.builtin.lsp').implementations({shorten_path = false})<CR>
nnoremap ,h <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap ,n <cmd>lua vim.lsp.buf.rename()<CR>
" Standard LSP stuff but specific for jdtls plugin
"noremap ,a <Cmd>lua require('jdtls').code_action()<CR>
" noremap ,f <Cmd>lua require('jdtls').code_action(false, 'refactor')<CR>

" DAP debugging
command! Dbr lua require('dap').toggle_breakpoint()
command! Dn lua require('dap').step_over()
command! Di lua require('dap').step_into()
command! Do lua require('dap').step_out()
command! Drepl lua require('dap').repl.open()
command! Dstart lua require('dap').continue()
command! Dclass lua require('jdtls').test_class()
command! Dtest lua require('jdtls').test_nearest_method()

" Otherwise substitution doesn't work multiple times per line
set nogdefault
