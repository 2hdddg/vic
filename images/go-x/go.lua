local lspconfig = require'lspconfig'
local util = require'lspconfig.util'

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

lspconfig.gopls.setup{
    cmd = {"gopls", "serve"},
    filetypes = {"go", "gomod"},
    root_dir = util.root_pattern("go.work", "go.mod", ".git"),
    capabilities = capabilities,
}
vim.api.nvim_command(' autocmd BufWritePre *.go lua vim.lsp.buf.formatting_sync(nil, 1000)')
