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
runtime treesitter.vim

set termguicolors
colorscheme srcery

lua <<EOF

-- Syntax highlighting
require'nvim-treesitter.configs'.setup {
--  ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,  -- false will disable the whole extension
  },
}

-- Auto completion
require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  resolve_timeout = 800;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = {
    border = { '', '' ,'', ' ', '', '', '', ' ' }, -- the border option is the same as `|help nvim_open_win|`
    winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
    max_width = 120,
    min_width = 60,
    max_height = math.floor(vim.o.lines * 0.3),
    min_height = 1,
  };

  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
  };
}

-- Status line
local function classInStatusLine()
    return require('nvim-treesitter').statusline({type_patterns={"class"},indicator_size=30})
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
  lightgray    = vim.g.srcery_xgray5,
}
local theme = {
  normal = {
    a = {bg = colors.green, fg = colors.black, gui = 'bold'},
    b = {bg = colors.gray, fg = colors.white},
    c = {bg = colors.gray, fg = colors.gray},
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
    b = {bg = colors.darkgray, fg = colors.white},
    c = {bg = colors.darkgray, fg = colors.gray},
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
    lualine_x = { {'diagnostics', sources = {'nvim_lsp'} } },
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {'filename'},
    lualine_c = {},
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
    vimgrep_arguments = { 'ag', '--vimgrep' },
  },
  pickers = {},
}
EOF


" Leader keys
nnoremap <leader>n <cmd>nohl<cr> " No hightlight
nnoremap <leader>f <cmd>lua require('telescope.builtin').git_files()<cr> " Find file among git files
nnoremap <leader>F <cmd>lua require('telescope.builtin').file_browser()<cr>
nnoremap <leader>q <cmd>lua require('telescope.builtin').quickfix()<cr>
nnoremap <leader>g <cmd>lua require('telescope.builtin').grep_string()<cr>
nnoremap <leader>c <cmd>lua require('telescope.builtin').git_bcommits()<cr>
nnoremap <leader>C <cmd>lua require('telescope.builtin').git_commits()<cr>

autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics({ focusable = false })
" autocmd CursorHoldI * silent! lua vim.lsp.buf.signature_help()
set updatetime=300 " CursorHold trigger time (and write to swap)

" LSP
" Map all standard LSP commands to ,X
nnoremap ,a <cmd>lua require('telescope.builtin').lsp_code_actions()<cr>
nnoremap ,d <cmd>lua require('telescope.builtin.lsp').definitions({shorten_path = false})<CR>
nnoremap ,r <cmd>lua require('telescope.builtin.lsp').references({shorten_path = false})<CR>
nnoremap ,D <cmd>lua require('telescope.builtin').lsp_document_diagnostics()<CR>
nnoremap ,W <cmd>lua require('telescope.builtin').lsp_workspace_diagnostics()<CR>
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
