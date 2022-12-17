
if vim.g.goplsSetup == 1 then
    do return end
end
local lspconfig = require'lspconfig'
local util = require'lspconfig.util'
local capabilities = require('cmp_nvim_lsp').default_capabilities()
lspconfig.gopls.setup{
    cmd = {"gopls", "serve"},
    filetypes = {"go", "gomod"},
    root_dir = util.root_pattern("go.work", "go.mod", ".git"),
    capabilities = capabilities,
}
vim.api.nvim_command(' autocmd BufWritePre *.go lua vim.lsp.buf.formatting_sync(nil, 1000)')
vim.g.goplsSetup = 1
