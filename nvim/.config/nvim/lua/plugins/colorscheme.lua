-- Colorscheme: tokyonight-night (dark) by default, matching kitty's Tokyo Night
-- (kitty/.config/kitty/current-theme.conf). PaperColor (light) is kept installed
-- and switchable with :colorscheme:
--   :colorscheme tokyonight-night   (the default)
--   :colorscheme tokyonight-storm   (dark, softer)
--   :colorscheme tokyonight-moon    (dark, cooler)
--   :colorscheme tokyonight-day     (light)
--   :colorscheme PaperColor         (light)
--   :colorscheme catppuccin-mocha   (and -macchiato / -frappe / -latte)
--   :colorscheme kanagawa-wave      (and -dragon / -lotus)
--
-- ITALICS ARE OFF ON PURPOSE, in BOTH schemes (tokyonight `styles`, PaperColor
-- `allow_italic = 0`). This is a font-metrics constraint, not taste: JetBrains
-- Mono advances 0.600 em per glyph but its ITALIC ink reaches 0.658 em, and kitty
-- clips each glyph to its cell. Italics would need `modify_font cell_width 110%`
-- in kitty.conf, and that 10% is added to EVERY character on screen, which reads
-- as badly spaced text. The two settings are COUPLED: turning italics back on
-- requires raising cell_width to 110%.
return {
    {
        "NLKNguyen/papercolor-theme",
        -- Not the default any more, but lazy = false keeps its colors/ dir on the
        -- runtimepath so it stays listed in `:colorscheme <Tab>`.
        lazy = false,
        priority = 900,
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
            -- The default is tokyonight-night, which sets background=dark, so a
            -- plain `:colorscheme PaperColor` would give the DARK variant.
            -- ColorSchemePre fires BEFORE the scheme loads, which is the only
            -- point where flipping `background` still affects the result.
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

    -- tokyonight is THE DEFAULT (see the LazyVim spec at the bottom). `style` only
    -- decides what bare `:colorscheme tokyonight` means; the named variants
    -- (tokyonight-night, -storm, ...) each force their own.
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "night",
            styles = {
                comments = { italic = false }, -- see the note above; coupled to cell_width
                keywords = { italic = false },
            },
            -- Window separators. tokyonight defines `border = black` (#15161e in
            -- night) -- its DARKEST color, darker than the editor (#1a1b26) and one
            -- step off the sidebar (#16161e), so the line between neo-tree and the
            -- code is 1.05:1 / 1.00:1: effectively not drawn. The theme means the
            -- darker sidebar background to be the boundary, but that is only a 4/255
            -- step in night. `border` feeds WinSeparator + VertSplit and nothing
            -- else, so re-pointing it at the palette's own grey fixes every split.
            -- Read off the palette, not a hex, so storm/moon/day retrack it.
            --   dark3 = 2.6:1 on the editor bg (clearly a line, not loud)
            --   fg_gutter = 1.7:1, the line-number grey, if this is too strong
            on_colors = function(c)
                c.border = c.dark3
            end,
        },
    },

    -- catppuccin + kanagawa: installed to SWITCH to, never the default.
    -- `lazy = false` keeps them listed in `:colorscheme <Tab>`.
    --   :colorscheme catppuccin-mocha / -macchiato / -frappe / -latte
    --   :colorscheme kanagawa-wave / -dragon / -lotus
    -- This merges with LazyVim's own catppuccin spec (integrations + bufferline
    -- theme; bufferline.lua only keeps that theme while catppuccin is active).
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        opts = {
            no_italic = true, -- see the note above; coupled to cell_width
        },
    },
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            commentStyle = { italic = false }, -- see the note above; coupled to cell_width
            keywordStyle = { italic = false },
            -- hardcoded italics the Style options don't reach (`this`/`self`, ...).
            -- Markdown *italic* text stays italic, same as tokyonight.
            overrides = function()
                local off = { italic = false }
                return {
                    ["@variable.builtin"] = off,
                    NeotestMarked = off,
                    NvimTreeOpenedFile = off,
                }
            end,
        },
    },

    {
        "scottmckendry/cyberdream.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            theme = "auto",
            highlights = {
                CursorLine = { bg = "#E0FFFF" },
                Visual = { bg = "#E0FFFF" },
            },
        },
    },
    {
        "projekt0n/github-nvim-theme",
        name = "github-theme",
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require("github-theme").setup({
                -- ...
            })
        end,
    },
    { "EdenEast/nightfox.nvim" },
    {
        "nickkadutskyi/jb.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        config = function()
            -- require("jb").setup({transparent = true})
            -- vim.cmd("colorscheme jb")
        end,
    },

    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "tokyonight-moon",
        },
    },
}
