return {
    {
        "stevearc/conform.nvim",
        opts = {
            formatters = {
                biome = {
                    -- 1. Disable the requirement for a config file
                    require_cwd = false,
                    -- 2. Explicitly tell Biome where to run if no root is found
                    --    (Use the file's own directory as the working directory)
                    cwd = require("conform.util").root_file({ "biome.json", "biome.jsonc" }),
                },
            },
        },
    },

    -- {
    --     "pmizio/typescript-tools.nvim",
    --     lazy = false,
    --     dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    --     opts = {},
    -- },
    {
        "neovim/nvim-lspconfig",
        opts = {

            servers = {

                vtsls = {
                    enabled = true,
                    filetypes = {
                        "javascript",
                        "javascriptreact",
                        "javascript.jsx",
                        "typescript",
                        "typescriptreact",
                        "typescript.tsx",
                        "vue",
                        -- "html",
                    },
                },

                html = {},
                typescript_tools = {
                    enabled = false,
                },
                tsserver = {
                    enabled = false,
                },
                ts_ls = {
                    enabled = false,
                },
                ember = {
                    enabled = false,
                },
            },
        },
    },

    -- Plugin for editing <script> tags in html files in proxy buffer
    -- which also provides support for correct attach `typescript` LSP
    -- {
    --     "AndrewRadev/inline_edit.vim",
    --     lazy = true,
    --     event = "VeryLazy",
    --     cmd = { "InlineEdit" },
    --     keys = {
    --         { "<leader>cI", "<cmd>InlineEdit<cr>", desc = "Inline Edit (JS inside <script> html)" },
    --     },
    --     config = function() end,
    -- },
    -- {
    --     "nvim-treesitter/nvim-treesitter",
    --     opts = function(_, opts)
    --         vim.treesitter.language.register("javascript", "html")
    --         vim.treesitter.language.register("typescript", "html")
    --     end,
    -- },
}
