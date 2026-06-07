return {
    {
        "dstein64/nvim-scrollview",
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
        end,
    },
}
