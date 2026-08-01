-- TERMINAL mode looks the same as NORMAL mode in the statusline: most auto lualine
-- themes tint terminal a muted teal that's too close to the normal-mode blue to
-- tell apart at a glance. Give terminal a clear RED instead -- unmistakable against
-- blue, and not colliding with the other modes (insert=green, visual=violet,
-- replace=orange, command=yellow).
--
-- The red and the text color are DERIVED from the active colorscheme rather than
-- pinned to a hex, so this survives a theme switch: a kanagawa hex would read as a
-- washed-out pink on a light theme like catppuccin-latte. DiagnosticError is the
-- one group every theme defines as "the red", and normal.a.fg is whatever the
-- theme already decided is legible on a saturated mode block.
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
        -- Read a hex fg off a highlight group, following links. Returns nil when the
        -- group is missing or has no fg, so the caller can fall back.
        local function hl_fg(name)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            if ok and hl and hl.fg then
                return string.format("#%06x", hl.fg)
            end
        end
        opts.options = opts.options or {}
        -- LazyVim leaves theme = "auto" (derived live from the colorscheme). Resolve
        -- it to a table so we can add a `terminal` section; we mirror normal's b/c so
        -- only the bold "a" block (the mode label) changes color.
        local theme = resolve(opts.options.theme or "auto")
        if type(theme) == "table" and type(theme.normal) == "table" then
            theme.terminal = {
                a = {
                    fg = (theme.normal.a or {}).fg,
                    bg = hl_fg("DiagnosticError") or "#e46876",
                    gui = "bold",
                },
                b = theme.normal.b,
                c = theme.normal.c,
            }
            opts.options.theme = theme
        end
    end,
}
