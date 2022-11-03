local clangd = require('lspconfig').clangd
local on_attach = function(client, bufnr)
    -- Map Clangd specific command to toggle between h/cpp
    local bufopts =  {noremap=true, silent=true, buffer=bufnr}
    vim.keymap.set('n', ',q', function()
        vim.cmd('ClangdSwitchSourceHeader')
    end, bufopts)
end

clangd.setup({
    on_attach = on_attach,
    -- Clangd specific settings
    cmd = { "clangd", "--all-scopes-completion", "--background-index", "--clang-tidy", "--header-insertion=iwyu", "--pretty" },
})
