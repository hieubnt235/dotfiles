-- Add server start/stop keymaps to the LazyVim claudecode extra (everything else
-- stays exactly as the extra defines it). Keys chosen so the LETTER is the last
-- letter of the action -- "starT" -> <leader>at, "stoP" -> <leader>ap -- and the
-- desc capitalizes that letter to make the mnemonic obvious. Both keys are free
-- (no clash with the extra's ac/af/ar/... or with as=send). No `mode` set, to match
-- the extra's own keys (they don't specify a mode -> default normal).
return {
    "coder/claudecode.nvim",
    -- Hide tmux from the Claude process. When $TMUX is set (nvim started inside
    -- tmux), Claude wraps its startup "what is your background colour?" query in
    -- tmux's passthrough envelope. But Claude is not talking to tmux here -- nvim's
    -- terminal sits in between, cannot parse the envelope, and prints its payload
    -- as text: the stray `11;?` in front of the logo. An empty value is enough;
    -- measured in a bare `nvim --clean` terminal: TMUX set -> `11;?`, TMUX="" -> clean.
    opts = { env = { TMUX = "" } },
    -- FUNCTION form APPENDS to the extra's keys instead of replacing them (a table
    -- here would clobber <leader>ac/af/ar/... entirely -- verified).
    keys = function(_, keys)
        vim.list_extend(keys, {
            {
                "<leader>at",
                -- Only start if the server is actually down; otherwise a calm INFO
                -- instead of claudecode's scary "already running" WARN. (The server is
                -- usually already up via auto_start, so plain :ClaudeCodeStart would
                -- warn every time. `state.server` is the verified running flag.)
                function()
                    local cc = require("claudecode")
                    if cc.state and cc.state.server then
                        vim.notify("Claude server already running", vim.log.levels.INFO, { title = "Claude" })
                    else
                        vim.cmd("ClaudeCodeStart")
                    end
                end,
                desc = "Star(t) the server",
            },
            { "<leader>ap", "<cmd>ClaudeCodeStop<cr>", desc = "Sto(p) the server" },
        })
    end,
}
