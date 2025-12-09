return {
    {
        "folke/snacks.nvim",
        opts = {
            bigfile = {
                enabled = true,
                size = 100 * 1024 * 1024, -- 100MB
                line_length = 100000,
            },
            quickfile = { enabled = true },
        },
    },
}
