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

    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {},
    },
    {
        "neovim/nvim-lspconfig",
        opts = {

            servers = {
                tsserver = {
                    enabled = false,
                },
                ts_ls = {
                    enabled = false,
                },
                vtsls = {
                    enabled = false,
                },
                ember = {
                    enabled = false,
                },
            },
        },
    },
}
