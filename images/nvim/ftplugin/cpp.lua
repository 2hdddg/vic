local clangd = require('lspconfig').clangd
local on_attach = function(client, bufnr)
    -- Map Clangd specific command to toggle between h/cpp
    local bufopts =  {noremap=true, silent=true, buffer=bufnr}
    vim.keymap.set('n', ',q', function()
        vim.cmd('ClangdSwitchSourceHeader')
    end, bufopts)
end
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local server = {
    on_attach = on_attach,
    capabilities = capabilities,
    -- Clangd specific settings
    cmd = { "clangd", "--all-scopes-completion", "--background-index", "--clang-tidy", "--header-insertion=iwyu", "--header-insertion-decorators", "--completion-style=detailed", "--pretty" },
}
require("clangd_extensions").setup({
    server = server,
})
vim.cmd('packadd termdebug')
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
