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
end, { desc = "neogit root (neogit)" })
vim.keymap.set("n", "<leader>gG", function()
    require("neogit").open()
end, { desc = "neogit cwd (neogit)" })

-- Terminal: leave terminal mode with a double <C-n> OR double <C-q>, instead of
-- the awkward <C-\><C-n>. We avoid mapping a bare <Esc> so <Esc> still reaches the
-- program (e.g. Claude Code's interrupt). Note: snacks terminals also support
-- <Esc><Esc> by default (single <Esc> passes through, double <Esc> -> normal mode).
vim.keymap.set("t", "<C-n><C-n>", [[<C-\><C-n>]], { desc = "Terminal: to normal mode" })
vim.keymap.set("t", "<C-q><C-q>", [[<C-\><C-n>]], { desc = "Terminal: to normal mode" })

-- <leader>g label convention: lowercase, with the owning plugin in parens.
-- The "Git " prefix is dropped -- the group is already called git.
-- These are the entries LazyVim sets with plain vim.keymap.set, so re-setting
-- them here wins (user config loads after LazyVim's). The lazy `keys` entries
-- (gd/gs/gS/ge + octo) are overridden in lua/plugins/git-names.lua.

-- gb/gB are REAL blame now. LazyVim had gb on Snacks.picker.git_log_line(),
-- which is `git log -L` (every commit touching the line), not blame at all.
vim.keymap.set("n", "<leader>gb", function()
    require("gitsigns").blame_line({ full = true })
end, { desc = "blame line (gitsigns)" })

-- Toggle: gitsigns.blame() only ever opens, so close it ourselves by finding
-- the window with its filetype. No internals -- `gitsigns-blame` is the ft the
-- plugin sets on its blame buffer.
vim.keymap.set("n", "<leader>gB", function()
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "gitsigns-blame" then
            vim.api.nvim_win_close(w, true)
            return
        end
    end
    require("gitsigns").blame()
end, { desc = "blame buffer (gitsigns)" })

-- <leader>gl = log via snacks (fuzzy list), <leader>gL = log via diffview
-- (side-by-side). Both are groups: b = whole branch, f = current file.
-- LazyVim binds gl/gL/gf directly, so drop those first or they shadow the group.
pcall(vim.keymap.del, "n", "<leader>gl")
pcall(vim.keymap.del, "n", "<leader>gL")
pcall(vim.keymap.del, "n", "<leader>gf")

vim.keymap.set("n", "<leader>glb", function() Snacks.picker.git_log() end, { desc = "whole branch (snacks)" })
vim.keymap.set("n", "<leader>glf", function() Snacks.picker.git_log_file() end, { desc = "current file (snacks)" })

-- gY (browse copy) removed -- LazyVim binds it, so delete it explicitly.
pcall(vim.keymap.del, { "n", "x" }, "<leader>gY")
