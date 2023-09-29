if vim.g.rustSetup == 1 then
    return
end
vim.g.rustSetup = 1

local nvim_lsp = require'lspconfig'

local on_attach = function(client)
    vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
    require'completion'.on_attach(client)
end
local capabilities = require('cmp_nvim_lsp').default_capabilities()
nvim_lsp.rust_analyzer.setup({
    on_attach=on_attach,
    capabilities = capabilities,
    settings = {
        ["rust-analyzer"] = {
            imports = {
                granularity = {
                    group = "module",
                },
                prefix = "self",
            },
            cargo = {
                buildScripts = {
                    enable = true,
                },
              allFeatures = true,
              autoReload = true,
              loadOutDirsFromCheck = true,
            },
            procMacro = {
                enable = true
            },
            assist = {
                importGranularity = "module",
                importPrefix = "by_self",
                importGroup = false,
            },
            completion = {
                addCallArgumentSnippets = true,
                addCallParenthesis = true,
                enableExperimental = true,
                autoimport = { enable = true },
                postfix = { enable = false, true },
            },
            lens = {
                enable = true,
            },
            workspace = {
                symbol = {
                  search = {
                    kind = "all_symbols",
                  },
                },
            },
        },
}})
