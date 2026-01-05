return {
    -- 1. Tell Mason to auto-install xmlformatter
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "xmlformatter",
            },
        },
    },

    -- 2. Tell Conform to use xmlformatter for XML files
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                xml = { "xmlformatter" },
            },
        },
    },
}
