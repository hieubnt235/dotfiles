-- TERMINAL mode looks the same as NORMAL mode in the statusline: kanagawa's auto
-- lualine theme tints terminal a muted teal (#7aa89f) that's too close to the
-- normal-mode blue (#7e9cd8) to tell apart at a glance. Give terminal a clear RED
-- instead -- unmistakable against blue, and not colliding with the other modes
-- (insert=green, visual=violet, replace=orange, command=yellow).
return {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
        local function resolve(t)
            if type(t) == "string" then
                local ok, mod = pcall(require, "lualine.themes." .. t)
                return ok and mod or nil
            end
            return t
        end
        opts.options = opts.options or {}
        -- LazyVim leaves theme = "auto" (derived live from kanagawa). Resolve it to
        -- a table so we can add a `terminal` section; we mirror normal's b/c so only
        -- the bold "a" block (the mode label) changes color.
        local theme = resolve(opts.options.theme or "auto")
        if type(theme) == "table" and type(theme.normal) == "table" then
            theme.terminal = {
                a = { fg = "#16161d", bg = "#e46876", gui = "bold" },
                b = theme.normal.b,
                c = theme.normal.c,
            }
            opts.options.theme = theme
        end
    end,
}
