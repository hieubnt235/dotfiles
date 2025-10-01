-- in lua/plugins/scrollview.lua
return {
    {
        "dstein64/nvim-scrollview",
        config = function()
            require("scrollview").setup({
                scrollview_winblend = 100,
                scrollview_winblend_gui = 100,
                signs_on_startup = {
                    "diagnostics",
                    "search",
                    "marks",
                    "cursor",
                    "keywords",
                },
                current_only = true,
            })
            vim.api.nvim_set_hl(0, "ScrollView", { bg = "#00bb00" })
        end,
    },
}
