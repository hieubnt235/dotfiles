-- Terminals: betterTerm in a floating window, one float, tabs in its winbar.
--   <C-\>          toggle the float (shows the last terminal; inside one: hide it)
--   <C-t>          (terminal mode, inside a terminal) new terminal tab
--   <S-h> / <S-l>  (normal mode, inside a terminal) previous / next tab --
--                  same keys as bufferline; <C-q><C-q> (keymaps.lua) gets you there
--   r              (normal mode, inside a terminal) rename the current tab
--   click a tab to switch.
-- <C-\> in terminal mode shadows nvim's <C-\><C-n> -- <C-q><C-q> replaces it.
--
-- New terminals go through open(next number): betterTerm's own "new terminal"
-- path (new_tab_mapping / the "+" tab) opens a second float on top of the first
-- in float mode (tested). new_tab_mapping can't be disabled (always mapped), so it
-- is parked on <C-S-t>, which kitty takes for its own new-tab and never passes on;
-- the "+" is hidden. The Claude panel and LazyVim's <C-/> (snacks) are untouched.

-- Highest terminal number open now, from betterTerm's buffer names "<name> (N)"
-- ("Term (2)", or "server (2)" after a rename).
local function last_number()
    local max = 0
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        local n = vim.bo[b].filetype == "better_term" and tonumber(vim.fn.bufname(b):match("%((%d+)%)$"))
        if n and n > max then
            max = n
        end
    end
    return max
end

return {
    {
        "CRAG666/betterTerm.nvim",
        keys = {
            {
                "<C-\\>",
                function()
                    require("betterTerm").toggle_termwindow()
                end,
                mode = { "n", "t" },
                desc = "Terminal (float)",
            },
        },
        opts = {
            display = "float",
            -- Half the editor each way, centered (fractions of the editor size).
            float_config = { width = 0.5, height = 0.5 },
            index_base = 1,
            new_tab_mapping = "<C-S-t>",
            new_tab_icon = "",
        },
        config = function(_, opts)
            local bt = require("betterTerm")
            -- Switching tabs with <S-h>/<S-l> stays in normal mode (i / a to type),
            -- like the snacks terminal; opening (<C-\>) and new tabs (<C-t>) still
            -- start in terminal mode. startInserted is read on every show.
            local cycling = false
            opts.startInserted = function()
                return not cycling
            end
            local function cycle(step)
                cycling = true
                pcall(bt.cycle, step)
                cycling = false
            end
            bt.setup(opts)
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("betterterm_keys", { clear = true }),
                pattern = "better_term",
                callback = function(ev)
                    local function map(mode, lhs, fn, desc)
                        vim.keymap.set(mode, lhs, fn, { buffer = ev.buf, desc = desc })
                    end
                    map("t", "<C-t>", function()
                        bt.open(last_number() + 1)
                    end, "New terminal")
                    map("n", "<S-h>", function()
                        cycle(-1)
                    end, "Prev terminal")
                    map("n", "<S-l>", function()
                        cycle(1)
                    end, "Next terminal")
                    -- betterTerm has rename() but no key or command for it. Stock r
                    -- (replace char) is useless here: terminal buffers are read-only.
                    map("n", "r", function()
                        bt.rename()
                    end, "Rename terminal")
                end,
            })
        end,
    },
}
