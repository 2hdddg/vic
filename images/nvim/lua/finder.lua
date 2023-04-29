local telescope = require'telescope'
local actions = require'telescope.actions'
local fb_actions = require "telescope._extensions.file_browser.actions"
telescope.setup{
  defaults = {
    layout_strategy = 'bottom_pane',
    sorting_strategy = "ascending",
    wrap_results = true,
    vimgrep_arguments = { 'ag', '--vimgrep' },
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      }
    },
  },
  extensions = {
      file_browser = {
          hijack_netrw = true,
          hidden = true,
          grouped = true,
      },
  },
}
telescope.load_extension('fzf')
telescope.load_extension('file_browser')
