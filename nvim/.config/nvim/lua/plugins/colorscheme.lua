return {
    -- {
    --     "LazyVim/LazyVim",
    --     opts = {
    --         -- colorscheme = "catppuccin",
    --         -- colorscheme = "mellifluous",
    --         colorscheme = "onenord",
    --     },
    -- },

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
    -- {
    --     "ramojus/mellifluous.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     opts = {
    --         main_keywords = { bold = true },
    --         other_keywords = {},
    --         types = { bold = true },
    --         operators = {},
    --         strings = {},
    --         functions = { bold = true },
    --         constants = {},
    --         comments = { italic = true },
    --         markup = {
    --             headings = { bold = true },
    --         },
    --         folds = {},
    --     },
    -- },
    {
        "rmehri01/onenord.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            theme = "light",
            styles = {
                comments = "italic",
                strings = "None",
                keywords = "bold",
                functions = "bold",
                variables = "NONE",
                diagnostics = "underline",
            },
        },
    },
}
