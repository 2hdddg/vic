local colors = require('colors')
local theme = {
    CursorLine = { bg=colors.xgray2, style="NONE" },
    CursorColumn = { bg=colors.xgray2 },
    MatchParen = { style = "inverse" },
    ColorColumn = { bg = colors.xgray2 },
    Conceal = { fg = colors.blue },
    CursorLineNr = { fg = colors.yellow, bg = colors.black },
    Visual = { fg='NONE', bg='NONE', style = "reverse" }, -- VisualNOS
    Search = { fg='NONE', bg='NONE', style = "reverse" },
    IncSearch = { fg='NONE', bg='NONE', style = "reverse" },
    Underlined = { fg=colors.blue, style = "underline" },
    Whitespace = { fg=colors.xgray3 },
    NonText = { link='Whitespace' },

    MoreMsg = {fg=colors.yellow, style="bold"},
    

    -- Completion menu
    Pmenu = { fg=colors.bright_white, bg=colors.xgray2 },
    PmenuSel = { fg=colors.bright_white, bg=colors.blue },
    PmenuSbar = { bg=colors.black },
    PmenuThumb = { bg=colors.black },

    -- Telescope, style as completion menu
    TelescopeNormal = { link = 'Pmenu' },
    TelescopePreviewNormal = { bg =colors.black }, -- Make preview of code look normal
    TelescopeSelection = { link = 'PmenuSel' },
    TelescopeMatching = {style = "reverse" },

    Directory = {fg=colors.green, style="bold"},
    Title = {fg=colors.green, style="bold"},
    LineNr = {fg=colors.bright_black},

    SignColumn = {bg=colors.black},
    Folded = {fg=colors.bright_black, bg=colors.black, style="italic"},
    FoldColumn = {fg=colors.bright_black, bg=colors.black},
    Cursor = {fg=colors.black, bg=colors.yellow},

    -- Syntax
    Boolean = {fg=colors.bright_magenta},
    Character = {fg=colors.bright_magenta},
    Comment = {fg=colors.xgray6, style="italic"},
    Conditional = {fg=colors.red},
    Constant = {fg=colors.bright_magenta},
    Define = {fg=colors.cyan, style="italic"},
    Delimiter = {fg=colors.bright_black},
    Exception = {fg=colors.red},
    Float = {fg=colors.bright_magenta},
    Function = {fg=colors.yellow},
    Include = {fg=colors.cyan, style="italic"},
    -- Ignore
    Keyword = {fg=colors.red},
    Label = {fg=colors.red},
    Macro = {link='Include'},
    -- MonText
    Number = {fg=colors.bright_magenta},
    Operator = {fg=colors.xorange},
    PreCondit = {fg=colors.cyan},
    PreProc = {link='Include'},
    -- Question
    Repeat = {fg=colors.red},
    -- Make special chars stick out from string
    Special = {fg=colors.red},
    -- SpecialComment
    Statement = {fg=colors.red},
    StorageClass = {fg=colors.xorange},
    String = {fg=colors.white, style="italic"},
    Structure = {fg=colors.cyan},
    Todo = {fg=colors.bright_white},
    Type = {fg=colors.green},
    Typedef = {fg=colors.cyan},
    -- Treesitter
    ['@namespace'] = {fg=colors.bright_black},
    ['@variable'] = {fg=colors.cyan},
    ['@parameter'] = {fg=colors.cyan, style="underline"},

    -- Used by netrw to show file
    -- In syntax?
    Identifier = {fg=colors.cyan},

    -- Diff
    DiffAdd = {fg=colors.green, bg=colors.black},
    DiffDelete = {fg=colors.red, bg=colors.black},
    DiffChange = {fg=colors.cyan, bg=colors.black},
    DiffText = {fg=colors.yellow, bg=colors.black},

    -- Lsp
    LspDiagnosticsDefaultError = {fg=colors.bright_red},
    LspDiagnosticsDefaultWarning = {fg=colors.bright_yellow},
    LspDiagnosticsDefaultInformation = {fg=colors.bright_green},
    LspDiagnosticsDefaultHint = {fg=colors.bright_cyan},
    LspDiagnosticsUnderlineError = {fg=colors.bright_red, style='underline'},
    LspDiagnosticsUnderlineWarning = {fg=colors.bright_yellow, style='underline'},
    LspDiagnosticsUnderlineInformation = {fg=colors.bright_green, style='underline'},
    LspDiagnosticsUnderlineHint = { fg=colors.bright_cyan, style='underline'},

    -- CMP
}

local function highlight(group, properties)
    local cmd = "highlight " 
    if (properties.link) then
        cmd = cmd .. "link " .. group .. " " .. properties.link
    else
        cmd = cmd .. group
        if properties.bg then
            cmd = cmd .. " ctermbg=" .. properties.bg
        end
        if properties.fg then
            cmd = cmd .. " ctermfg=" .. properties.fg
        end
        if properties.style then
            cmd = cmd .. " cterm=" .. properties.style
        end
    end
    vim.cmd(cmd)
end

vim.o.background = "dark"
vim.cmd("highlight clear")
for group, properties in pairs(theme) do
    highlight(group, properties)
end
-- Setup treesitter to use highlighting
require('nvim-treesitter.configs').setup({
    highlight = {
        enable = true,
    },
})
