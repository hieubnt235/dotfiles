-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.shiftwidth = 4
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.editorconfig = false
vim.g.lazyvim_prettier_needs_config = false
vim.opt.conceallevel = 0
vim.opt.concealcursor = ""
-- vim.opt.scroll = 10
-- vim.g.clangd_inactive_regions = 0

vim.api.nvim_set_hl(0, "LspInactiveRegion", { link = "Normal" })
-- vim.lsp.inlay_hint.enable(false)

vim.keymap.set("n", "<A-l>", function()
    vim.cmd("normal! zl")
end)

vim.keymap.set("n", "<A-h>", function()
    vim.cmd("normal! zh")
end)

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
