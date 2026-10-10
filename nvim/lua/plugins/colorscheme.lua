local p = require("config.gruvbox_palette")

return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {
      contrast = "hard",
      transparent_mode = true,
      overrides = {
        -- Transparency for chrome surfaces gruvbox's transparent_mode doesn't
        -- already cover (it only strips bg on Normal/NormalFloat/SignColumn/etc).
        StatusLine = { bg = "NONE", fg = p.fg1 },
        StatusLineNC = { bg = "NONE", fg = p.fg4 },
        WinBar = { bg = "NONE", fg = p.fg4 },
        WinBarNC = { bg = "NONE", fg = p.fg3 },
        TabLineFill = { bg = "NONE", fg = p.bg4 },
        TabLine = { bg = "NONE", fg = p.fg4 },
        Pmenu = { bg = "NONE" },
        PmenuSbar = { bg = "NONE" },

        -- Chrome/navigation recolor: swap gruvbox's accent colors (green,
        -- blue, orange, red...) for plain bg/fg scale on UI-frame elements,
        -- same idea as the grayscale tmux-gruvbox bar and starship prompt.
        -- Code syntax groups (Function, String, Type, ...) are untouched.
        TabLineSel = { bg = "NONE", fg = p.fg0, bold = true },
        PmenuSel = { bg = p.bg2, fg = p.fg0, bold = true },
        CursorLineNr = { fg = p.fg0, bg = "NONE" },

        SnacksPickerMatch = { fg = p.fg0, bold = true },
        SnacksPickerPrompt = { fg = p.fg2 },
        SnacksPickerDir = { fg = p.fg4 },

        TelescopeMatching = { fg = p.fg0, bold = true },
        TelescopePromptPrefix = { fg = p.fg2 },
        TelescopeSelectionCaret = { fg = p.fg0 },

        WhichKey = { fg = p.fg0 },
        WhichKeyGroup = { fg = p.fg2 },
        WhichKeyDesc = { fg = p.fg1 },
        WhichKeyValue = { fg = p.fg4 },
        WhichKeySeparator = { fg = p.bg4 },
        WhichKeyFloat = { bg = "NONE" },
        WhichKeyBorder = { bg = "NONE", fg = p.bg3 },

        SnacksDashboardHeader = { fg = p.fg3 },
        SnacksDashboardFooter = { fg = p.fg4 },
        SnacksDashboardKey = { fg = p.fg0, bold = true },
        SnacksDashboardDesc = { fg = p.fg1 },
      },
    },
    config = function(_, opts)
      require("gruvbox").setup(opts)
      vim.cmd.colorscheme("gruvbox")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "gruvbox" },
  },
}
