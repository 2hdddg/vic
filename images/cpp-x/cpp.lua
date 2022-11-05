local clangd = require('lspconfig').clangd
local on_attach = function(client, bufnr)
    -- Map Clangd specific command to toggle between h/cpp
    local bufopts =  {noremap=true, silent=true, buffer=bufnr}
    vim.keymap.set('n', ',q', function()
        vim.cmd('ClangdSwitchSourceHeader')
    end, bufopts)
end
require('cmp_nvim_lsp').default_capabilities()

clangd.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    -- Clangd specific settings
    cmd = { "clangd", "--all-scopes-completion", "--background-index", "--clang-tidy", "--header-insertion=iwyu", "--header-insertion-decorators", "--completion-style=detailed", "--pretty" },
})
