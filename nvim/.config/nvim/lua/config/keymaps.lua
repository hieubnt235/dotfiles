-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<C-z>", "u", { noremap = true, silent = true })
vim.keymap.set("i", "<C-z>", "<C-o>u", { noremap = true, silent = true })
-- normal-mode mappings: scroll by 10 lines
vim.keymap.set("n", "<C-d>", "15<C-d>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "15<C-u>", { noremap = true, silent = true })
