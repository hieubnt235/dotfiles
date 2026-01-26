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
            local namespace_color = "darkcyan"
            local class_color = "lightseagreen"
            -- local directive_color = "dodgerblue"
            local directive_color = "magenta"
            local function_color = "darkblue"
            require("github-theme").setup({
                options = {
                    styles = {
                        functions = "NONE",
                        -- strings = "italic",
                        -- comments = "italic",
                        -- keywords = "bold",
                        -- types = "italic,bold",
                    },
                },
                groups = {
                    github_light_default = {

                        -- Targets the 'ns' in 'ns::Member'
                        ["@module"] = { fg = namespace_color },
                        -- Targets 'ns' specifically in C++/Rust scope resolution
                        ["@namespace"] = { fg = namespace_color },
                        -- Optional: If you want the '::' to be a specific color
                        ["@punctuation.delimiter"] = { fg = namespace_color },

                        ["@keyword"] = { fg = "blue" },
                        ["@type.builtin"] = { fg = "blue" },
                        ["@keyword.directive"] = { fg = directive_color },
                        ["@keyword.import"] = { fg = directive_color },
                        -- ["@keyword.vim"] = { fg = "indianred" },
                        --
                        ["@function"] = { fg = function_color },
                        ["@function.call"] = { fg = function_color },
                        ["@function.method"] = { fg = function_color },
                        ["@function.method.call"] = { fg = function_color },
                        ["@function.builtin"] = { fg = function_color },
                        ["@method"] = { fg = function_color },
                        ["@method.call"] = { fg = function_color },
                        ["@constructor"] = { fg = function_color },
                    },
                },
                specs = {
                    github_light_default = {
                        syntax = {
                            -- keyword = "blue",
                            builtin0 = "blue",
                            builtin1 = "blue",
                            builtin2 = "blue",
                            conditional = "blue",
                            func = function_color,
                            preproc = directive_color,
                            type = class_color,
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
