-- Rounded borders for the COMPLETION popups, so every floating window in the
-- editor reads as one family:
--   noice  -> hover (K) + signature docs + cmdline   (plugins/noice.lua)
--   blink  -> completion menu + its doc window       (here)
-- blink.cmp defaults all three of these to `border = nil`, i.e. a flat block with
-- no edge, which is why the completion menu still looked unlike the hover popup.
--
-- NOTE: these are separate plugins. There is no single global switch --
-- `vim.o.winborder` does not reach either of them, because noice and blink both
-- build their windows from their own config rather than Neovim's default.
return {
    "saghen/blink.cmp",
    opts = {
        completion = {
            menu = { border = "rounded" }, -- the candidate list
            documentation = {
                window = { border = "rounded" }, -- the doc panel beside it
            },
        },
        signature = {
            -- plugins/snippets.lua sets `signature = { enabled = true }` at the
            -- SPEC level rather than inside `opts`, where lazy.nvim ignores it.
            -- Enabling it here (the correct place) actually turns it on.
            enabled = true,
            window = { border = "rounded" },
        },
    },
}
