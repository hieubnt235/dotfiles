-- Colorscheme: PaperColor, light variant. The ONLY theme installed.
--
-- PaperColor is a vimscript scheme: it exposes ONE name and picks light vs dark
-- from `&background`, so `vim.o.background = "light"` is pinned in
-- config/options.lua -- without it you get the dark variant.
--   :colorscheme PaperColor
--
-- Options must be set BEFORE the scheme loads, hence `init` (which lazy.nvim runs
-- at startup) rather than `opts` -- a vimscript plugin has no setup().
--
-- ITALICS ARE OFF ON PURPOSE (`allow_italic = 0`). This is a font-metrics
-- constraint, not taste: JetBrains Mono advances 0.600 em per glyph but its
-- ITALIC ink reaches 0.658 em, and kitty clips each glyph to its cell. Italics
-- would need `modify_font cell_width 110%` in kitty.conf, and that 10% is added to
-- EVERY character on screen, which reads as badly spaced text. The two settings
-- are COUPLED: turning italics back on requires raising cell_width to 110%.
return {
    {
        "NLKNguyen/papercolor-theme",
        lazy = false,
        priority = 1000,
        init = function()
            vim.g.PaperColor_Theme_Options = {
                theme = {
                    default = {
                        allow_bold = 1,
                        allow_italic = 0, -- see the note above; coupled to cell_width
                    },
                },
            }

            -- PaperColor paints methods AND class members the same near-black
            -- (`Function` #444444, `@variable.member` #14161b), so you cannot tell
            -- a call from a field. Rider's Melon Light separates them by SHADE
            -- rather than hue: both purple, the member a touch deeper.
            -- Reproduced here -- same hue, member darker. No `bold` is used: bold
            -- changes stroke weight (and glyph ink), the deeper purple alone reads
            -- as "a little bolder" without thickening the text.
            local METHOD = "#6B2FBA" -- Melon's DEFAULT_FUNCTION_* purple
            local MEMBER = "#4A1D82" -- same hue, ~30% darker
            vim.api.nvim_create_autocmd("ColorScheme", {
                pattern = "PaperColor",
                callback = function()
                    local set = function(groups, fg)
                        for _, g in ipairs(groups) do
                            vim.api.nvim_set_hl(0, g, { fg = fg })
                        end
                    end
                    -- Both the Treesitter and the LSP groups must be set: clangd's
                    -- semantic tokens (@lsp.type.*) win over Treesitter, so setting
                    -- only one of the two leaves the colour changing once the LSP
                    -- attaches.
                    set({
                        "@function",
                        "@function.call",
                        "@function.method",
                        "@function.method.call",
                        "@lsp.type.function",
                        "@lsp.type.method",
                    }, METHOD)
                    set({
                        "@variable.member",
                        "@property",
                        "@field",
                        "@lsp.type.property",
                        "@lsp.type.field",
                    }, MEMBER)
                end,
            })
        end,
    },

    -- LazyVim ships its own tokyonight + catppuccin specs, so removing them from
    -- this file is not enough -- they have to be disabled explicitly or lazy.nvim
    -- keeps reinstalling them. `enabled = false` lets `:Lazy clean` delete them.
    { "folke/tokyonight.nvim", enabled = false },
    { "catppuccin/nvim", enabled = false },

    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "PaperColor",
        },
    },
}
