local lspconfig = require'lspconfig'
local lspconfig_util = require'lspconfig.util'

local root_dir = function(fname)
    local root
    root = lspconfig_util.root_pattern 'go.work'(fname)
    if root then
        return root
    end
    root = lspconfig_util.root_pattern('go.mod', '.git')(fname)
    if root then
        return root
    end
    -- This makes it possible to go to definition in modules in modcache that are not modules themselves.
    -- All imports in those modules are still failing.. Remove this root_dir thing completely when this
    -- part is not needed anymore.
    local deps_root = '/host/workspace/pkg/mod'
    if fname:sub(1, string.len(deps_root)) == deps_root then
        return deps_root
    end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

lspconfig.gopls.setup{
    root_dir = root_dir,
    capabilities = capabilities,
}
vim.api.nvim_command(' autocmd BufWritePre *.go lua vim.lsp.buf.formatting_sync(nil, 1000)')
