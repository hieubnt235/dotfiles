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

        -- Smooth scrolling tuning (faster than default; skip terminal buffers).
        scroll = {
            animate = {
                duration = { step = 10, total = 70 },
                easing = "linear",
            },
            -- faster animation when repeating scroll after delay
            animate_repeat = {
                delay = 10, -- delay in ms before using the repeat animation
                duration = { step = 5, total = 50 },
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
