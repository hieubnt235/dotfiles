-- Layer 2 cockpit: Neogit (Magit-style, verb-first). Replaces lazygit.
-- Kept at defaults; Neogit auto-detects the diffview + gitsigns you already have.
-- Opened with <leader>gg (set in lua/config/keymaps.lua).
return {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Neogit",
    opts = {
        -- Pin the layer-3 viewer instead of relying on auto-detect order.
        -- Neogit also supports "codediff"; we deliberately use diffview.
        diff_viewer = "diffview",
    },
}
