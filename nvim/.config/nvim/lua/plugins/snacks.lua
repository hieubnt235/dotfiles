-- All snacks.nvim configuration lives in THIS file (don't scatter snacks opts
-- across multiple plugin files). LazyVim deep-merges these opts with its own.
return {
    "folke/snacks.nvim",
    opts = {
        -- Big-file handling: disable heavy features on huge files so they open fast.
        bigfile = {
            enabled = true,
            size = 100 * 1024 * 1024, -- 100MB
            line_length = 100000,
        },
        quickfile = { enabled = true },

        -- Image preview (PNG/JPG/etc). svg is deliberately NOT added to formats:
        -- snacks ERASES a buffer's text and replaces it with the image when it
        -- renders (placement.lua), so listing svg would make .svg un-editable. To get
        -- BOTH edit + view, .svg stays as XML text and a separate-split image preview
        -- is toggled via <leader>mp (see autocmds.lua). Needs imagemagick+librsvg2-bin.
        image = { enabled = true },

        -- Start screen.
        dashboard = {
            preset = {
                header = [[
██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗    ██╗  ██╗ █████╗ ██████╗ ██████╗
██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝    ██║  ██║██╔══██╗██╔══██╗██╔══██╗
██║ █╗ ██║██║   ██║██████╔╝█████╔╝     ███████║███████║██████╔╝██║  ██║
██║███╗██║██║   ██║██╔══██╗██╔═██╗     ██╔══██║██╔══██║██╔══██╗██║  ██║
╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗    ██║  ██║██║  ██║██║  ██║██████╔╝
 ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝
]],
            },
        },

        -- Pickers: make find-files (Space Space) and grep (Space /) reach hidden +
        -- ignored files too. Toggle per-search inside the picker with <a-h>/<a-i>.
        picker = {
            sources = {
                files = { hidden = true, ignored = true },
                grep = { hidden = true, ignored = true },
            },
        },

        -- Smooth scrolling (snacks bundles this; it's OFF by default, so enable it).
        -- Animates <C-d>/<C-u>, mouse wheel, n/N, etc. Terminal buffers are skipped.
        -- `total` = the animation length in ms. Raise for slower, lower for snappier.
        -- <C-d>/<C-u> travel 3/4 of a window (see config/keymaps.lua).
        -- `total` = how long the whole motion takes, in ms. THIS is the speed
        -- knob: raise it to slow the scroll down, lower it for snappier.
        -- `step` is only the frame interval. Snacks' own defaults are 200 / 50.
        scroll = {
            enabled = true,
            animate = {
                duration = { step = 10, total = 100 },
                easing = "linear",
            },
            -- Used when <C-d> repeats (held down). Much shorter than the single
            -- press above, otherwise each frame queues behind the last and the
            -- scroll lags behind the key. `delay` = ms of repeating before this
            -- kicks in; snacks defaults that to 100, which is too late to help.
            animate_repeat = {
                -- Snacks marks a scroll as a "repeat" only when it arrives
                -- within `delay` ms of the previous one (scroll.lua:305):
                --     is_repeat = repeat_delta <= animate_repeat.delay
                -- Key auto-repeat fires every ~30-50ms, so the old value of 10
                -- never matched and this whole block was dead -- holding <C-d>
                -- kept using the slow single-press animation. 100 is snacks' own
                -- default and comfortably covers the key-repeat interval.
                delay = 100,
                duration = { step = 4, total = 40 },
                easing = "linear",
            },
            -- what buffers to animate
            filter = function(buf)
                return vim.g.snacks_scroll ~= false
                    and vim.b[buf].snacks_scroll ~= false
                    and vim.bo[buf].buftype ~= "terminal"
            end,
        },
    },
}
