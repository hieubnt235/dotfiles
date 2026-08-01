-- Colorscheme: catppuccin, "latte" flavour -- the LIGHT one, for bright rooms.
-- Flavours (all bundled in this one theme, so it adapts to the room across a day):
--   catppuccin-latte      = light (current)
--   catppuccin-frappe     = dark, lowest contrast / warmest
--   catppuccin-macchiato  = dark, mid contrast
--   catppuccin-mocha      = darkest / most contrast
-- Switch live with:  :colorscheme catppuccin-mocha   (or -frappe / -macchiato)
--
-- LazyVim already ships a catppuccin spec with the full integrations list
-- (neo-tree, gitsigns, mini, trouble, native_lsp, ...), so we only add the
-- flavour + the WinSeparator override on top of it.
return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        opts = {
            flavour = "latte",
            -- Brighten the window divider -- the default WinSeparator is too dim to
            -- see clearly. overlay0 is the mid gray: visible against latte's light
            -- background without being harsh (bump to overlay1/overlay2 for more).
            -- (Neo-tree hidden/ignored "access" styling -- dim + italic -- is handled
            -- dynamically in explorer.lua, not here, because it must blur whatever
            -- color git already gave the file rather than a fixed highlight.)
            custom_highlights = function(colors)
                return {
                    WinSeparator = { fg = colors.overlay0 },
                }
            end,
        },
    },
    -- Kept installed so `:colorscheme kanagawa-wave` (or -dragon / -lotus) still
    -- works as an instant switch back. `lazy = true` keeps it off the startup path;
    -- lazy.nvim loads it on demand the moment you name it in :colorscheme.
    {
        "rebelot/kanagawa.nvim",
        lazy = true,
        opts = {
            compile = false,
            background = { dark = "wave", light = "lotus" },
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
            colorscheme = "catppuccin-latte",
        },
    },
}
