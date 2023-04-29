local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = {
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<C-j>'] = cmp.mapping.select_next_item(),
          -- select = false -> Need to select something
          ['<CR>'] = cmp.mapping.confirm({select = false}),
          ['<TAB>'] = cmp.mapping.confirm({select = true}),
          ['<C-Space>'] = cmp.mapping.complete(),
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
    view = { entries = "custom", },
    window = {
      completion = cmp.config.window.bordered({
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
      }),
      -- In the way sometimes...
      --documentation = cmp.config.window.bordered({
      --  winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
      --}),
  },
})
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = 'cmdline' }, },
    formatting = { fields = { "abbr" }, },
})
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = 'buffer' } },
    formatting = { fields = { "abbr" } },
})
