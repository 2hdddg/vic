require("formatter").setup({
        filetype = {
            -- Forward actual formatting to script in workspace
            java = {
                function()
                    return {
                        exe = "/host/workspace/format",
                        args = { "-" },
                        stdin = true,
                    }
                end
            }
        }
    })

-- Formatting on save for different languages
vim.api.nvim_exec([[
augroup FormatAutogroup
    autocmd!
    autocmd BufWritePost *.java FormatWrite
augroup END
]], true)
