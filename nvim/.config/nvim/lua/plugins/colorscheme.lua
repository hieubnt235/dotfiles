return {
    -- {
    --     "catppuccin/nvim",
    --     -- name = "catppuccin",
    --     lazy = false,
    --     priority = 1000,
    --     opts = {
    --         flavour = "latte", -- latte, frappe, macchiato, mocha
    --         styles = {
    --             loops = {},
    --             functions = {},
    --             keywords = {},
    --             strings = {},
    --             variables = {},
    --             numbers = {},
    --             booleans = {},
    --             properties = {},
    --             types = {},
    --             operators = {},
    --         },
    --     },
    -- },
    -- {
    --     "yorik1984/newpaper.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     config = true,
    --     opts = {
    --         -- terminal = "bg",
    --         -- style = "auto",
    --         style = "light",
    --         greyscale = false,
    --         lightness = -0.05,
    --         saturation = 1,
    --         keywords = "NONE",
    --         booleans = "NONE",
    --         booleans_operators = "NONE",
    --         operators_bold = false,
    --         italic_strings = false,
    --         -- delim_rainbow_bold = true,
    --         -- brackets_bold = true,
    --         -- tags = "italic",
    --     },
    -- },
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
    --
    {
        "projekt0n/github-nvim-theme",
        name = "github-theme",
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require("github-theme").setup({
                options = {
                    styles = {
                        -- strings = "italic",
                        -- comments = "italic",
                        -- keywords = "bold",
                        -- types = "italic,bold",
                    },
                },
                specs = {
                    github_light_default = {
                        syntax = {
                            string = "red",
                            comment = "green",
                        },
                    },
                },
            })
            -- vim.cmd("colorscheme    github_light_default")
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "github_light_default",
        },
    },
}
