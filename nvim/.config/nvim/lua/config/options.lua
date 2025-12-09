-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.shiftwidth = 4
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.editorconfig = false
-- vim.g.lazyvim_prettier_needs_config = true
vim.opt.conceallevel = 0
vim.opt.concealcursor = ""

-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "json" },
--     callback = function()
--         vim.opt_local.tabstop = 4
--         vim.opt_local.shiftwidth = 4
--         vim.opt_local.softtabstop = 4
--         vim.opt_local.expandtab = true -- optional, ensures spaces instead of tabs
--     end,
-- })
