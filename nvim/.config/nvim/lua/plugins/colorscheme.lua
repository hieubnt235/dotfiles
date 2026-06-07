-- Colorscheme: kanagawa -- stable (top-3 most installed), full Treesitter +
-- clangd LSP semantic-token coverage (messy C++ stays correctly colored), and a
-- muted/warm/low-contrast palette that's gentle for long (10h/day) sessions.
-- Variants (all bundled in this one theme, so it adapts to the room across a day):
--   kanagawa-dragon  = darkest, lowest contrast -> gentlest on the eyes (default)
--   kanagawa-wave    = default dark (a bit more color/contrast)
--   kanagawa-lotus   = light, for bright rooms / daytime
-- Switch live with:  :colorscheme kanagawa-lotus   (or -wave / -dragon)
return {
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            compile = false,
            -- `:colorscheme kanagawa` follows these per background; we pin dragon below.
            background = { dark = "wave", light = "lotus" },
            -- Brighten the window divider -- kanagawa's default WinSeparator is too
            -- dim to see clearly. fujiGray (the comment gray) is visible without
            -- being harsh; bump to colors.palette.oldWhite for even brighter.
            overrides = function(colors)
                return {
                    WinSeparator = { fg = colors.palette.fujiGray },
                }
            end,
        },
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "kanagawa",
        },
    },
}
