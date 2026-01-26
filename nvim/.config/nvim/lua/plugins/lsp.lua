return {
    -- { "Civitasv/cmake-tools.nvim", enabled = true },
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
                    mason = true,
                    init_options = {
                        fallbackFlags = { "--std=c++23" },
                    },

                    cmd = {
                        "clangd",
                        "--background-index",
                        "-j=8",
                        "--clang-tidy",
                        "--header-insertion=iwyu",
                        "--completion-style=detailed",
                        "--function-arg-placeholders",
                        "--fallback-style=llvm",
                        "--experimental-modules-support",
                        "--query-driver=**/*",
                    },
                    on_attach = function(client, _)
                        -- Disable semantic tokens so Treesitter handles the highlighting
                        client.server_capabilities.semanticTokensProvider = nil
                    end,
                    -- on_attach = function(client, bufnr)
                    --     -- Delay hint updates to avoid stale columns
                    --     vim.defer_fn(function()
                    --         if vim.api.nvim_buf_is_valid(bufnr) then
                    --             vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    --         end
                    --     end, 200)
                    -- end,
                },
                neocmakelsp = {},
                ["*"] = {
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
            -- Disable snippetSupport
            -- capabilities = require("blink.cmp").get_lsp_capabilities({
            --     textDocument = {
            --         completion = {
            --             completionItem = {
            --                 snippetSupport = false,
            --             },
            --         },
            --     },
            -- }),
        },
    },
}
