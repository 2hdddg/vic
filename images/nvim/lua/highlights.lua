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
    Directory = {fg=colors.green, style="bold"},
    Title = {fg=colors.green, style="bold"},
    LineNr = {fg=colors.bright_black},
    SignColumn = {bg=colors.black},
    Folded = {fg=colors.bright_black, bg=colors.black, style="italic"},
    FoldColumn = {fg=colors.bright_black, bg=colors.black},
    Cursor = {fg=colors.black, bg=colors.yellow},
    -- Popup border and background
    FloatBorder = {fg=colors.yellow},
    NormalFloat = {bg=colors.black},

    -- Completion menu
    Pmenu = { fg=colors.bright_white, bg=colors.black },
    PmenuSel = { style="reverse" },
    PmenuSbar = { bg=colors.black },
    PmenuThumb = { bg=colors.black },

    -- Telescope, style as completion menu
    TelescopeNormal = { link = 'Pmenu' },
    TelescopePreviewNormal = { bg =colors.black }, -- Make preview of code look normal
    TelescopeSelection = { link = 'PmenuSel' },
    TelescopeMatching = {style = "reverse" },

    -- Syntax
    -- Used by netrw to show file
    -- Also default linked to in syntax
    Identifier = {fg=colors.white},
    -- Built in language keywords
    Keyword = {fg=colors.red},
    Repeat = {link='Keyword'},
    Statement = {link='Keyword'},
    Conditional = {link='Keyword'},
    ['@type.qualifier'] = {link='Keyword'},
    -- Stuff loke void/float..
    ['@type.builtin'] = {link='Keyword'},
    -- Constants (like literals but also semantic)
    Constant = {fg=colors.green},
    Boolean = {link='Constant'},
    Character = {link='Constant'},
    Float = {link='Constant'},
    Number = {link='Constant'},
    ['@lsp.mod.readonly'] = {link='Constant'},
    -- Special constant is string
    String = {fg=colors.bright_black, style="italic"},
    -- Scope of variables (instance vars)
    ['@lsp.typemod.property.classScope'] = {fg=colors.xbright_orange},
    -- Type
    Type = {fg=colors.cyan},
    -- Separators
    Operator = {fg=colors.bright_black},
    Delimiter = {link='Operator'},
    -- Comment
    Comment = {fg=colors.xgray6, style="italic"},
    -- Preprocessor
    PreProc = {fg=colors.blue, style="italic"},
    Define = {link='PreProc'},
    Include = {link='PreProc'},
    Macro = {link='PreProc'},

    Exception = {fg=colors.red},
    Function = {fg=colors.yellow},
    Label = {fg=colors.red},
    PreCondit = {fg=colors.cyan},
    -- Make special chars stick out from string
    Special = {fg=colors.red},
    -- SpecialComment
    StorageClass = {fg=colors.xorange},
    --Structure = {fg=colors.cyan},
    --Todo = {fg=colors.bright_white},
    --Typedef = {fg=colors.cyan},
    -- Treesitter
    ['@namespace'] = {fg=colors.bright_black},
    ['@variable'] = {fg=colors.white},
    ['@parameter'] = {link='@variable'},
    ['@field'] = {link='@variable'},
    ['@property'] = {link='@variable'},
    ['@constructor'] = {link='Function'},
    ['@function.call'] = {link='Function'},
    ['@attribute'] = {fg=colors.xorange},

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

    -- Fex
    FexFile = { fg=colors.cyan },

    -- TermDebug
    debugPC = { bg=colors.xgray6, style="NONE" },
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
