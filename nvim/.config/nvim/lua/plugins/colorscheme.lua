-- Colorscheme: PaperColor (light) by default. tokyonight is kept installed and
-- switchable with :colorscheme -- see the spec below for the variant names.
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

            -- PaperColor is ONE scheme with two variants, chosen from `&background`.
            -- Nothing pins that any more (the default is tokyonight-night, which
            -- sets background=dark), so `:colorscheme PaperColor` would give the
            -- DARK variant. ColorSchemePre fires BEFORE the scheme loads, which is
            -- the only point where flipping `background` still affects the result.
            vim.api.nvim_create_autocmd("ColorSchemePre", {
                pattern = "PaperColor",
                callback = function()
                    vim.o.background = "light"
                end,
            })

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

                    -- flash.nvim (`s`) is unreadable on PaperColor: it links
                    -- FlashMatch -> Search and FlashLabel -> Substitute, and
                    -- PaperColor defines those two IDENTICALLY (#444444 on
                    -- #ffff5f). Label and match end up the same yellow, so you
                    -- cannot tell which character to press. Give each its own
                    -- colour: label = red (the key you type), match = blue
                    -- (where you could go), current = the original yellow.
                    local hl = function(g, o)
                        vim.api.nvim_set_hl(0, g, o)
                    end
                    hl("FlashLabel", { fg = "#ffffff", bg = "#d70000", bold = true })
                    hl("FlashMatch", { fg = "#444444", bg = "#d7d7ff" })
                    hl("FlashCurrent", { fg = "#444444", bg = "#ffff5f" })
                    hl("FlashBackdrop", { fg = "#a8a8a8" })
                end,
            })
        end,
    },

    -- tokyonight is kept AVAILABLE (not active) so it can be switched to with
    -- :colorscheme. lazy = false because lazy.nvim has no `colorscheme` trigger --
    -- an unloaded plugin's `colors/` dir is not on the runtimepath, so :colorscheme
    -- would fail with E185. priority is left below PaperColor's 1000, so PaperColor
    -- still wins at startup.
    --   :colorscheme tokyonight-night   (dark)
    --   :colorscheme tokyonight-storm   (dark, softer)
    --   :colorscheme tokyonight-moon    (dark, cooler)
    --   :colorscheme tokyonight-day     (light)
    --   :colorscheme PaperColor         (back to the default)
    -- NOTE: options.lua pins vim.o.background = "light" for PaperColor. Each
    -- tokyonight VARIANT sets its own background, so the named variants above work
    -- regardless; bare `:colorscheme tokyonight` follows the pinned light instead.
    { "folke/tokyonight.nvim", lazy = false, priority = 900 },

    -- LazyVim ships a catppuccin spec too; disabled explicitly or lazy.nvim keeps
    -- reinstalling it. `enabled = false` lets `:Lazy clean` delete it.
    { "catppuccin/nvim", enabled = false },

    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "PaperColor",
        },
    },
}
