if vim.g.goplsSetup == 1 then
    return
end
local on_attach = function(client, bufnr)
    vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
end
local lspconfig = require'lspconfig'
local util = require'lspconfig.util'
local capabilities = require('cmp_nvim_lsp').default_capabilities()
lspconfig.gopls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
}
vim.g.goplsSetup = 1
