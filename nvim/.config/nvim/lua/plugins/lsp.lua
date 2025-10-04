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
        capabilities = require("blink.cmp").get_lsp_capabilities({
            textDocument = {
                completion = {
                    completionItem = {
                        snippetSupport = false,
                    },
                },
            },
        }),
    },
}
