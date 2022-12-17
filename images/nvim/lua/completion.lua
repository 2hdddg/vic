local cmp = require('cmp')
local border = {
      { "╭" },
      { "─"},
      { "╮"},
      { "│"},
      { "╯"},
      { "─"},
      { "╰"},
      { "│"},
}
cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = {
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<CR>'] = cmp.mapping.confirm({select = true}),
          ['<C-e>'] = cmp.mapping {
              i = cmp.mapping.abort(),
              c = cmp.mapping.close(),
          },
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp'},
        { name = 'vsnip'},
        { name = 'nvim_lsp_signature_help'},
    }, {
        { name = 'buffer' },
        { name = 'path' },
    }),
    window = {
        completion = {
            border = border,
        },
        documentation = {
            border = border,
        },
  },
})