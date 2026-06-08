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
        -- `total` = the animation length in ms. Middle ground: slower than the old
        -- 70 (felt too fast to follow) but well under the snacks default of 250
        -- (which feels sluggish). Raise `total` for slower, lower for snappier.
        scroll = {
            enabled = true,
            animate = {
                duration = { step = 10, total = 130 },
                easing = "linear",
            },
            -- faster variant when you repeat-scroll quickly (e.g. mashing <C-d>)
            animate_repeat = {
                delay = 10, -- delay in ms before using the repeat animation
                duration = { step = 5, total = 90 },
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
