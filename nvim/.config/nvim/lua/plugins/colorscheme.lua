return {
    -- {
    --     "catppuccin/nvim",
    --     -- name = "catppuccin",
    --     lazy = false,
    --     priority = 1000,
    --     opts = {
    --         flavour = "latte", -- latte, frappe, macchiato, mocha
    --         styles = {
    --             loops = { "italic" },
    --             functions = { "bold" },
    --             keywords = { "bold" },
    --             strings = {},
    --             variables = {},
    --             numbers = {},
    --             booleans = {},
    --             properties = {},
    --             types = { "bold" },
    --             operators = {},
    --         },
    --     },
    -- },
    {
        "yorik1984/newpaper.nvim",
        lazy = false,
        priority = 1000,
        config = true,
        opts = {
            -- terminal = "bg",
            -- style = "auto",
            style = "light",
            greyscale = false,
            lightness = -0.05,
            saturation = 1,
            keywords = "NONE",
            booleans = "NONE",
            booleans_operators = "NONE",
            operators_bold = false,
            -- delim_rainbow_bold = true,
            -- brackets_bold = true,
            -- tags = "italic",
        },
    },
    -- {
    --     "rmehri01/onenord.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     opts = {
    --         theme = "light",
    --         styles = {
    --             comments = "italic",
    --             strings = "None",
    --             keywords = "bold",
    --             functions = "bold",
    --             variables = "NONE",
    --             diagnostics = "underline",
    --         },
    --     },
    -- },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "newpaper",
        },
    },
}
