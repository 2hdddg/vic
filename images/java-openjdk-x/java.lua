local jdtls = require'jdtls'
local jdtls_setup = require'jdtls.setup'
local home = vim.env.HOME
-- One dedicated LSP server & client will be started per unique root_dir
local project_root = jdtls_setup.find_root({'.git', 'mvnw', 'gradlew'})
-- Points to where eclipse jdt ls is built
local eclipse_build = home .. '/eclipse.jdt.ls'
local eclipse_jar = eclipse_build .. '/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar'
local eclipse_config = eclipse_build .. '/config_linux'
local workspace_path = '/host/workspace/jdtls'

-- Invoked for each buffer where Java LSP is attached
local on_attach = function(client, bufnr)
    jdtls_setup.add_commands()
    jdtls.setup_dap()
end

local jdtls_config = {
  -- The command that starts the language server
  cmd = {
    '/usr/bin/java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms2g',
    '-Xmx4G',
    '-jar', eclipse_jar,
    '-configuration', eclipse_config,
    '-data', workspace_path,
    '--add-modules=ALL-SYSTEM',
    '--add-opens java.base/java.util=ALL-UNNAMED',
    '--add-opens java.base/java.lang=ALL-UNNAMED',
  },
  root_dir = project_root,
  capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
  on_attach = on_attach,
  -- Debug support through VSCode java debug plugin
  init_options = {
    bundles = {
      vim.fn.glob(home .. "/eclipse_plugins/*.jar"),
    },
    settings = {
      java = {
        autobuild = { enabled = true },
        signatureHelp = { enabled = true },
        contentProvider = { preferred = 'fernflower' },
        import = {
          gradle = { enabled = false },
        },
        format = {
            enabled = true,
            settings = {
                url = "file:///host/workspace/codestyle-eclipse-java.xml",
                profile = "neo4j",
            }
        },
      },
      eclipse = {
        downloadSources = { enabled = true },
      },
    },
  },
}
jdtls.start_or_attach(jdtls_config)

-- Configure dap (only needed once but done on every attach now..)
local dap = require'dap'
dap.configurations.java = {
    {
        name = "Attach",
        type = "java",
        request = "attach",
        hostName = "localhost",
        port = 5005,
        projectName = "neo4j",
    },
}
