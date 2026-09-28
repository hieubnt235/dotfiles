-- oxc first: ONE formatter and ONE linter per file, picked by precedence.
--
--   formatter                                 linter (JS/TS/Vue/...)
--   1. oxfmt     project has oxfmt config     1. oxlint  project has oxlint config
--   2. prettier  else, prettier config        2. eslint  else, eslint config
--   3. biome     else, biome.json             3. biome   else, biome.json
--   4. oxfmt     else (nothing configured)    4. oxlint  else (built-in rules)
--
-- oxfmt reads .oxfmtrc.json (printWidth 120, proseWrap always, ...), so a file
-- saved in nvim is byte-identical to one saved in CLion.
--
-- Before: LazyVim's extras CHAINED formatters -- prettier -> biome-check ->
-- oxfmt all ran, even in a prettier-only project -- markdown ran prettier ->
-- markdownlint-cli2 -> markdown-toc, and oxlint only started when a
-- .oxlintrc.json existed. "Has a config" for prettier / biome / eslint is their
-- own stock check (prettier: vim.g.lazyvim_prettier_needs_config = true in
-- config/options.lua; biome-check: require_cwd; eslint / biome LSP: the
-- nvim-lspconfig root_dir, which only starts them when their config exists).
local oxfmt_config = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }
local oxlint_config = { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts" }
-- File types oxfmt formats (oxc extra's list + md/html/yaml checked on 0.65).
-- true = biome formats it too (LazyVim biome extra's list).
local fts = {
    javascript = true,
    javascriptreact = true,
    typescript = true,
    typescriptreact = true,
    json = true,
    jsonc = true,
    vue = true,
    svelte = true,
    astro = true,
    css = true,
    scss = true,
    markdown = false,
    ["markdown.mdx"] = false,
    html = false,
    yaml = false,
}

-- Nearest oxlint config, preferring the top-level one (monorepos) -- same
-- lookup as LazyVim's oxc extra.
local function oxlint_root(bufnr)
    local git = vim.fs.root(bufnr, ".git")
    return git and vim.fs.root(git, oxlint_config) or vim.fs.root(bufnr, oxlint_config)
end

-- Would this stock root_dir start its server for bufnr? (= project configures it)
local function starts(root_dir, bufnr)
    local hit = false
    if root_dir then
        root_dir(bufnr, function()
            hit = true
        end)
    end
    return hit
end

return {
    {
        "stevearc/conform.nvim",
        opts = function(_, opts)
            opts.formatters_by_ft = opts.formatters_by_ft or {}
            for ft, biome in pairs(fts) do
                opts.formatters_by_ft[ft] = biome and { "oxfmt", "prettier", "biome-check", stop_after_first = true }
                    or { "oxfmt", "prettier", stop_after_first = true }
            end
            opts.formatters = opts.formatters or {}
            opts.formatters.oxfmt = vim.tbl_extend("force", opts.formatters.oxfmt or {}, {
                -- oxfmt steps aside only for a project that configures another
                -- formatter for this file type and has no oxfmt config.
                condition = function(_, ctx)
                    if vim.fs.root(ctx.dirname, oxfmt_config) then
                        return true
                    end
                    local conform = require("conform")
                    local others = fts[vim.bo[ctx.buf].filetype] and { "prettier", "biome-check" } or { "prettier" }
                    for _, name in ipairs(others) do
                        if conform.get_formatter_info(name, ctx.buf).available then
                            return false
                        end
                    end
                    return true
                end,
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            -- The stock root_dirs, captured before LazyVim installs ours.
            local stock_eslint = vim.lsp.config.eslint.root_dir
            local stock_biome = vim.lsp.config.biome.root_dir
            opts.servers = opts.servers or {}
            opts.servers.oxlint = vim.tbl_deep_extend("force", opts.servers.oxlint or {}, {
                root_dir = function(bufnr, on_dir)
                    local root = oxlint_root(bufnr)
                    if root then
                        return on_dir(root)
                    end
                    if starts(stock_eslint, bufnr) or starts(stock_biome, bufnr) then
                        return
                    end
                    on_dir(vim.fs.root(bufnr, ".git") or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
                end,
            })
            opts.servers.eslint = vim.tbl_deep_extend("force", opts.servers.eslint or {}, {
                root_dir = function(bufnr, on_dir)
                    if not oxlint_root(bufnr) then
                        stock_eslint(bufnr, on_dir)
                    end
                end,
            })
            opts.servers.biome = vim.tbl_deep_extend("force", opts.servers.biome or {}, {
                root_dir = function(bufnr, on_dir)
                    if not oxlint_root(bufnr) and not starts(stock_eslint, bufnr) then
                        stock_biome(bufnr, on_dir)
                    end
                end,
            })
        end,
    },
    -- No markdownlint. The markdown extra lints with markdownlint-cli2, whose
    -- defaults (MD013 80-column lines, MD025 one `#` heading, ...) contradict
    -- oxfmt's 120-column output. CLion runs no Markdown linter either (and
    -- oxlint doesn't read Markdown).
    {
        "mfussenegger/nvim-lint",
        opts = function(_, opts)
            opts.linters_by_ft = opts.linters_by_ft or {}
            opts.linters_by_ft.markdown = {}
        end,
    },
}
