return {
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "catppuccin",
        },
    },

    {
        "catppuccin/nvim",
        -- name = "catppuccin",
        lazy = false,
        priority = 1000,
        opts = {
            flavour = "latte", -- latte, frappe, macchiato, mocha
            styles = {
                loops = { "italic" },
                functions = { "bold" },
                keywords = { "bold" },
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = { "bold" },
                operators = {},
            },
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
}
