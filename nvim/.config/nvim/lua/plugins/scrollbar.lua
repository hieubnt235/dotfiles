return {
    {
        "dstein64/nvim-scrollview",
        -- gitsigns must be loaded first: the contrib integration reads its sign
        -- config and hooks its hunk updates.
        dependencies = { "lewis6991/gitsigns.nvim" },
        config = function()
            require("scrollview").setup({
                signs_on_startup = {
                    "diagnostics",
                    "search",
                    "marks",
                    "cursor",
                    "keywords",
                },
                current_only = true,
            })
            -- No color override: ScrollView defaults to linking `Visual`, so the
            -- scrollbar follows the active theme (kanagawa) instead of a hardcoded
            -- color. (Sign colors -- diagnostics/search/etc -- are theme-derived too.)

            -- Show git add/change/delete marks on the scrollbar (CLion-style).
            -- Symbols/colors are inherited from gitsigns, so they match the gutter.
            require("scrollview.contrib.gitsigns").setup()
        end,
    },
}
