return {
    { "Civitasv/cmake-tools.nvim", enabled = false },
    {
        "Mythos-404/xmake.nvim",
        opts = {
            sections = {
                lualine_y = {
                    {
                        function()
                            if not vim.g.loaded_xmake then
                                return ""
                            end
                            local Info = require("xmake.info")
                            if Info.mode.current == "" then
                                return ""
                            end
                            if Info.target.current == "" then
                                return "Xmake: Not Select Target"
                            end
                            return ("%s(%s)"):format(Info.target.current, Info.mode.current)
                        end,
                        cond = function()
                            return vim.o.columns > 100
                        end,
                    },
                },
            },
        },
    },
    {
        "mason.nvim",
        opts = { ensure_installed = { "neocmakelsp" } },
    },

    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                clangd = {
                    mason = false,
                    init_options = {
                        fallbackFlags = { "--std=c++23" },
                    },

                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--header-insertion=iwyu",
                        "--completion-style=detailed",
                        "--function-arg-placeholders",
                        "--fallback-style=llvm",
                        "--experimental-modules-support",
                    },
                },
                neocmakelsp = {},
            },
            -- Disable snippetSupport
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
    },
}
