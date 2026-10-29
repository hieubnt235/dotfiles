-- render-markdown comes from LazyVim's lang.markdown extra, which strips its look
-- down (heading icons = {}, signs off, code width = "block", checkboxes off) --
-- with no icon the raw "#"/"##" stay visible, so it doesn't look like the
-- plugin's README. Drop those overrides so render-markdown runs on its own
-- defaults instead of values copied here.
return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = function(_, opts)
            opts.heading = nil
            opts.checkbox = nil
            -- One change from the defaults: code.border = "hide" conceals the ```
            -- fence lines (conceal_lines), and snacks.image draws a mermaid/math
            -- image as virtual lines on the closing fence -- a concealed line takes
            -- its virtual lines with it, so the diagram only showed with the cursor
            -- on that line. "thick" draws the fences as a background strip instead.
            opts.code = { border = "thick" }
        end,
    },
}
