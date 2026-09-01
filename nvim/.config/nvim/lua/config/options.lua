-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4 -- a tab displays as 4 columns (match CLion's default)
-- PaperColor is one colorscheme with two variants and picks between them from
-- `&background`, which Neovim defaults to "dark". Pin it light here (options.lua
-- loads before plugins) or you get the dark PaperColor.
vim.o.background = "light"
-- Use neo-tree as the file tree (toggle with <leader>e). LazyVim auto-disables the
-- snacks explorer when this is set, but keeps the snacks picker for find/grep.
-- neo-tree docks cleanly in edgy: resizable + size persists across toggles.
vim.g.lazyvim_explorer = "neo-tree"
vim.g.lazyvim_python_lsp = "basedpyright"
-- Respect .editorconfig (built into Neovim). This is THE cross-editor standard
-- for indentation -- CLion / VSCode / Neovim all read the same file, so a project
-- looks identical everywhere. (Was disabled before, which is why nvim and CLion
-- disagreed on tab width.)
vim.g.editorconfig = true
vim.g.lazyvim_prettier_needs_config = false
vim.opt.conceallevel = 0
vim.opt.concealcursor = ""
-- NOTE: do NOT set `vim.o.winborder` here. It is global and repaints every float,
-- including noice's cmdline popup (which already had the look you wanted), while
-- NOT fixing LSP hover -- noice intercepts hover and renders it from its own view
-- config, so the global option never reaches it. Hover borders belong in
-- plugins/noice.lua instead.
-- `list` is on (LazyVim default). Render tab indentation as BLANK instead of
-- LazyVim's "tab:> " -- otherwise every tab-indented line shows ">" markers
-- (this codebase is tab-indented). Keep trailing-space / nbsp warnings, which
-- are genuinely useful. Indentation structure still shows via snacks indent guides.
vim.opt.listchars = { tab = "▏ ", trail = "-", nbsp = "+" }
-- vim.opt.scroll = 10
-- vim.g.clangd_inactive_regions = 0

vim.api.nvim_set_hl(0, "LspInactiveRegion", { link = "Normal" })
-- vim.lsp.inlay_hint.enable(false)

-- (Removed redundant <A-h>/<A-l> horizontal scroll -- duplicated <A-y>/<A-e> in
-- keymaps.lua, and horizontal scrolling is covered by <A-d>/<A-u>.)

-- vim.keymap.set("n", "<leader>th", function()
--     vim.lsp.buf.type_hierarchy("subtypes")
-- end)
--
-- vim.keymap.set("n", "<leader>tH", function()
--     vim.lsp.buf.type_hierarchy("supertypes")
-- end)
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "json" },
--     callback = function()
--         vim.opt_local.tabstop = 4
--         vim.opt_local.shiftwidth = 4
--         vim.opt_local.softtabstop = 4
--         vim.opt_local.expandtab = true -- optional, ensures spaces instead of tabs
--     end,
-- })
