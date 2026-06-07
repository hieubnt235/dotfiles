-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<C-z>", "u", { noremap = true, silent = true })
vim.keymap.set("i", "<C-z>", "<C-o>u", { noremap = true, silent = true })
-- normal-mode mappings: scroll by 10 lines
vim.keymap.set("n", "<C-d>", "15<C-d>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "15<C-u>", { noremap = true, silent = true })

-- horizontal scroll (needs nowrap, which is the LazyVim default).
-- Ctrl+EDYU = vertical scroll, Alt+EDYU = horizontal scroll. Alt works in EVERY
-- terminal (no kitty-protocol dependency). Mirrors the vertical *behavior*:
--   Alt+E/Y = nudge view, cursor stays      (like Ctrl+E/Y, mouse-wheel feel)
--   Alt+D/U = half-screen jump, cursor moves (like Ctrl+D/U)
--   E/D = right, Y/U = left
vim.keymap.set("n", "<A-e>", "zl", { noremap = true, silent = true })
vim.keymap.set("n", "<A-y>", "zh", { noremap = true, silent = true })
vim.keymap.set("n", "<A-d>", "zL", { noremap = true, silent = true })
vim.keymap.set("n", "<A-u>", "zH", { noremap = true, silent = true })
