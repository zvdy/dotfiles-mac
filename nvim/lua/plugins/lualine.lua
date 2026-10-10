local p = require("config.gruvbox_palette")

-- Flat grayscale theme: same colors regardless of mode (normal/insert/visual/...),
-- cascading bg4 -> bg3 -> bg1 like the starship prompt and tmux-gruvbox bar,
-- instead of lualine's default per-mode accent colors (green/orange/purple/...).
local block = {
  a = { bg = p.bg4, fg = p.bg0, gui = "bold" },
  b = { bg = p.bg3, fg = p.fg0 },
  c = { bg = p.bg1, fg = p.fg2 },
}
local gruvbox_chrome = {
  normal = block,
  insert = block,
  visual = block,
  replace = block,
  command = block,
  terminal = block,
  inactive = {
    a = { bg = p.bg1, fg = p.fg4 },
    b = { bg = p.bg1, fg = p.fg4 },
    c = { bg = p.bg1, fg = p.fg4 },
  },
}

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}
    opts.options.theme = gruvbox_chrome
    return opts
  end,
}
