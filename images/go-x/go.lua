local lspconfig = require'lspconfig'
local lspconfig_util = require'lspconfig.util'

local root_dir = function(fname)
    return lspconfig_util.root_pattern 'go.work'(fname) or lspconfig_util.root_pattern('go.mod', '.git', '/host/workspace/pkg/mod')(fname)
end

lspconfig.gopls.setup{
    root_dir = root_dir,
}
vim.api.nvim_command(' autocmd BufWritePre *.go lua vim.lsp.buf.formatting_sync(nil, 1000)')
