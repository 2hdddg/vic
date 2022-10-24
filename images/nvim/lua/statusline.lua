local function classInStatusLine()
    return require('nvim-treesitter').statusline({type_patterns={"class"},indicator_size=50})
end

local function recordingMacro()
    local reg = vim.fn.reg_recording()
    if reg == "" then
        return reg
    end
    return "Recording @" .. reg
end

local colors = {
  black        = vim.g.srcery_black,
  white        = vim.g.srcery_bright_white,
  red          = vim.g.srcery_red,
  green        = vim.g.srcery_green,
  blue         = vim.g.srcery_blue,
  yellow       = vim.g.srcery_yellow,
  orange       = vim.g.srcery_bright_orange,
  gray         = vim.g.srcery_xgray3,
  darkgray     = vim.g.srcery_xgray1,
  lightgray    = vim.g.srcery_xgray6,
}
local theme = {
  normal = {
    a = {bg = colors.green, fg = colors.black, gui = 'bold'},
    b = {bg = colors.red, fg = colors.black, gui = 'bold'},
    c = {bg = colors.lightgray, fg = colors.darkgray},
    x = {bg = colors.black, fg = colors.black},
    y = {bg = colors.orange, fg = colors.black},
    z = {bg = colors.orange, fg = colors.black},
  },
  insert = {
    a = {bg = colors.blue, fg = colors.black, gui = 'bold'},
    z = {bg = colors.orange, fg = colors.black},
  },
  visual = {
    a = {bg = colors.yellow, fg = colors.black, gui = 'bold'},
    z = {bg = colors.orange, fg = colors.black},
  },
  replace = {
    a = {bg = colors.red, fg = colors.black, gui = 'bold'},
    z = {bg = colors.orange, fg = colors.black},
  },
  command = {
    a = {bg = colors.gray, fg = colors.black, gui = 'bold'},
    z = {bg = colors.orange, fg = colors.black},
  },
  inactive = {
    a = {bg = colors.darkgray, fg = colors.lightgray},
    b = {bg = colors.darkgray, fg = colors.lightgray},
    c = {bg = colors.darkgray, fg = colors.lightgray},
    x = {bg = colors.darkgray, fg = colors.lightgray},
    y = {bg = colors.darkgray, fg = colors.lightgray},
    z = {bg = colors.darkgray, fg = colors.lightgray},
  }
}
require'lualine'.setup {
  options = {
    icons_enabled = false,
    theme = theme,
    component_separators = {'', ''},
    section_separators = {'', ''},
    disabled_filetypes = {'class'}
  },
  sections = {
    lualine_a = {'filename'},
    lualine_b = {recordingMacro},
    lualine_c = {classInStatusLine},
    lualine_x = {{'diagnostics', sources = {'nvim_diagnostic'}}},
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
  tabline = {},
  extensions = {}
}

