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
        -- clangd is PINNED to 23.1.0. mason-registry still ships 22.1.6 as "latest"
        -- (checked 2026-09-08), and 22 cannot read the clang-23 BMIs emscripten
        -- produces, so <=22 reports every C++20 module as "not found". Mason accepts
        -- pkg@version, so this installs 23.1.0 on a fresh clone with no manual step.
        -- Mason's UI will still offer an "update" to 22.1.6 -- that is a DOWNGRADE;
        -- this pin is what stops `ensure_installed` from taking it. Raise the version
        -- here once the registry catches up.
        opts = { ensure_installed = { "neocmakelsp" } },
        -- clangd is PINNED to 23.1.0 here rather than in ensure_installed, because
        -- LazyVim passes those strings straight to mason-registry.get_package(),
        -- which has no idea what "clangd@23.1.0" means and errors out. Mason's own
        -- Package.Parse does understand pkg@version, so do the install ourselves.
        --
        -- Why pin at all: mason-registry still lists 22.1.6 as latest (2026-09-08),
        -- and clangd <=22 cannot read the clang-23 BMIs emscripten produces, so every
        -- C++20 module reads as "not found". Mason's UI will keep offering an
        -- "update" to 22.1.6 -- that is a DOWNGRADE; ignore it. Raise this string
        -- once the registry catches up.
        init = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = "VeryLazy",
                once = true,
                callback = function()
                    local ok, mr = pcall(require, "mason-registry")
                    if not ok then
                        return
                    end
                    mr.refresh(function()
                        local name, version = require("mason-core.package").Parse("clangd@23.1.0")
                        local okp, pkg = pcall(mr.get_package, name)
                        if not okp then
                            return
                        end
                        if not pkg:is_installed() or pkg:get_installed_version() ~= version then
                            pkg:install({ version = version })
                        end
                    end)
                end,
            })
        end,
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

                    -- clangd resolves compile_commands.json from each FILE's own
                    -- directory. emscripten's std.cppm lives under the emsdk sysroot,
                    -- which has no database above it, so clangd cannot build `std`.
                    -- Everything does `import std;`, so every module reads as "not
                    -- found" and the server WEDGES: requests keep arriving, no replies
                    -- go out, CPU pegged at ~200% indefinitely. Force ONE database for
                    -- all files, taken from root_dir so it follows whichever project
                    -- is open (no hardcoded paths).
                    --
                    -- This MUST be decided BEFORE the process is spawned, which is why
                    -- `cmd` is a function rather than a table + `before_init`.
                    -- vim/lsp/client.lua starts the RPC process ("Start the RPC
                    -- client", ~line 483) and only runs before_init afterwards inside
                    -- Client:initialize() (~line 570) -- so mutating config.cmd there
                    -- never reaches the spawned command line. A `cmd` FUNCTION is the
                    -- supported pre-spawn hook: client.lua calls it in place of
                    -- lsp.rpc.start() and uses whatever rpc object it returns.
                    --
                    -- "clangd" stays unqualified: mason prepends its bin dir to PATH,
                    -- so this picks up the pinned 23.1.0 without an absolute path.
                    -- The root is ALWAYS where nvim was opened -- you run `nvim .`
                    -- at the project top, so that is the project, full stop.
                    --
                    -- Without this, lspconfig walks up from each FILE looking for
                    -- root_markers, and `compile_commands.json` is one of them
                    -- (nvim-lspconfig/lsp/clangd.lua:68-76). The per-package
                    -- switching symlink at pkgs/<pkg>/compile_commands.json therefore
                    -- looks like a project root, so opening pkgs/sb-web/src/cpp/*.cpp
                    -- started a SECOND clangd rooted there -- its own
                    -- --compile-commands-dir, its own module cache, its own flags.
                    -- Verified: root_dir came back as .../pkgs/sb-web for that file
                    -- while cwd was the project top.
                    --
                    -- Defining root_dir disables root_markers entirely
                    -- (|lsp-root_markers|: "Unused if root_dir is defined"), which is
                    -- exactly what we want -- no marker hunting at all. The function
                    -- form MUST call on_dir, or the server never attaches.
                    root_dir = function(_, on_dir)
                        on_dir(vim.uv.cwd())
                    end,
                    cmd = function(dispatchers, config)
                        local cmd = {
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
                        }
                        if config.root_dir then
                            table.insert(cmd, "--compile-commands-dir=" .. config.root_dir)
                        end
                        return vim.lsp.rpc.start(cmd, dispatchers, {
                            cwd = config.cmd_cwd,
                            env = config.cmd_env,
                            detached = config.detached,
                        })
                    end,
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
