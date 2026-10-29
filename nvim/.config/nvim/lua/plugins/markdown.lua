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
            opts.code = nil
            opts.checkbox = nil
        end,
    },
}
