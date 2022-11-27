local telescope = require'telescope'
telescope.setup{
  defaults = {
    layout_strategy = 'bottom_pane',
    sorting_strategy = "ascending",
    wrap_results = true,
    vimgrep_arguments = { 'ag', '--vimgrep' },
  },
}
telescope.load_extension('fzf')
