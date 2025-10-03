return {
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
            clangd = {
                init_options = {
                    fallbackFlags = { "--std=c++20" },
                },
            },
        },
    },
}
