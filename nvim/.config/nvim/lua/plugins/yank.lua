return {
    {
        "ibhagwan/smartyank.nvim",
        event = "VeryLazy",
        opts = {
            highlight = { timeout = 1000 },
            osc52 = {
                enabled = true,
                -- escseq = 'tmux',     -- use tmux escape sequence, only enable if
                -- you're using tmux and have issues (see #4)
                ssh_only = false, -- false to OSC52 yank also in local sessions
                silent = false, -- true to disable the "n chars copied" echo
                echo_hl = "Directory", -- highlight group of the OSC52 echo message
            },
        },
    },
}
