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

-- Git cockpit: Neogit replaces lazygit on the same keys (gg = repo root, gG = cwd).
vim.keymap.set("n", "<leader>gg", function()
    require("neogit").open({ cwd = LazyVim.root.git() })
end, { desc = "Neogit (Root Dir)" })
vim.keymap.set("n", "<leader>gG", function()
    require("neogit").open()
end, { desc = "Neogit (cwd)" })

-- Terminal: leave terminal mode with a double <C-n> OR double <C-q>, instead of
-- the awkward <C-\><C-n>. We avoid mapping a bare <Esc> so <Esc> still reaches the
-- program (e.g. Claude Code's interrupt). Note: snacks terminals also support
-- <Esc><Esc> by default (single <Esc> passes through, double <Esc> -> normal mode).
vim.keymap.set("t", "<C-n><C-n>", [[<C-\><C-n>]], { desc = "Terminal: to normal mode" })
vim.keymap.set("t", "<C-q><C-q>", [[<C-\><C-n>]], { desc = "Terminal: to normal mode" })
