-- noice.nvim owns the LSP hover popup (K), so `vim.o.winborder` never reaches it
-- -- noice renders hover from its OWN view config. Setting the global option
-- instead repaints every other float (notably noice's cmdline popup, which already
-- looked right), so the border belongs here.
return {
    "folke/noice.nvim",
    opts = {
        presets = {
            -- Built-in noice preset. Flips views.hover.border.style from "none"
            -- (a flat block with no edge -- the "ugly pixel" look) to "rounded",
            -- and nudges the popup off the cursor by a row/col. Scoped to the
            -- hover + signature-help docs ONLY; the cmdline popup is untouched.
            lsp_doc_border = true,
        },
        views = {
            hover = {
                -- The lsp_doc_border preset only overrides border.STYLE, so noice's
                -- default `padding = { 0, 2 }` survived and left hover with twice
                -- the inset of blink's completion menu (draw.padding = 1). Restate
                -- the whole border table so style and padding are both pinned and
                -- all popups share a 1-column inset.
                -- (The 1-cell frame itself is not tunable: a TUI paints on the
                -- character grid, so a border always costs one whole cell per side.)
                border = {
                    style = "rounded",
                    padding = { 0, 1 },
                },
                win_options = {
                    -- config/options.lua pins a global `conceallevel = 0` so
                    -- markdown SOURCE stays visible while editing .md files. That
                    -- also leaked into hover, which is why docs showed literal
                    -- "### enum Method" and "**bold**" instead of styled text.
                    -- Set it per-window here so real buffers keep conceallevel 0.
                    conceallevel = 2,
                    concealcursor = "n",
                },
            },
        },
    },
}
