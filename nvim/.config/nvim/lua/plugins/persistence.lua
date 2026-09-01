-- Session persistence: reopen where you left off.
--
-- Two halves, each owning what it knows about:
--   tmux (resurrect + continuum, see tmux.conf.local) -> windows, panes, layout,
--        per-pane working directory. Deliberately NOT the running programs.
--   persistence.nvim (here)                            -> open buffers, cursor
--        positions, window splits, folds -- per project directory AND git branch.
--
-- persistence.nvim is a thin wrapper around `:mksession`; its README states it
-- "will never restore a session automatically". The VimEnter hook below is that
-- missing automatic half, so a restart reopens the project.
--
-- NOT PERSISTED: the <C-/> terminal. snacks creates its terminal buffer with
-- `buflisted = false`, and :mksession only records LISTED buffers, so it is
-- skipped. Neovim does have a `terminal` flag for 'sessionoptions' ("include
-- terminal windows where the command can be restored"), but it does not help
-- here -- verified: with it enabled the session file still contains no term://
-- entry, because the buffer is unlisted. snacks documents no session support.
-- Reopen it with <C-/>; a shell has no state to restore anyway.
--
-- Manual controls stay available:
--   <leader>qs  restore session for this directory
--   <leader>ql  restore the last session
--   <leader>qS  pick a session
--   <leader>qd  stop saving the current session
return {
    "folke/persistence.nvim",
    opts = {
        need = 1, -- save once at least one real file buffer is open
        -- Separate sessions per git branch: switching branches gives you the files
        -- you had open on that branch rather than the other one's.
        branch = true,
    },
    init = function()
        vim.api.nvim_create_autocmd("VimEnter", {
            group = vim.api.nvim_create_augroup("persistence_autoload", { clear = true }),
            -- `nested` so restored buffers fire their own FileType/LSP autocmds;
            -- without it the session loads but nothing attaches to the buffers.
            nested = true,
            callback = function()
                -- Restore only when nvim was opened to browse a PROJECT, not to edit
                -- one specific thing. Two cases count as "project":
                --   `nvim`     -- no arguments at all
                --   `nvim .`   -- a single DIRECTORY argument  <-- how you start it
                -- Anything else (`nvim foo.cpp`, a git commit buffer, piped stdin)
                -- means you asked for that file, so a session must not clobber it.
                -- snacks' dashboard makes the same distinction (dashboard.lua:1123).
                local argc = vim.fn.argc(-1)
                if argc > 1 then
                    return
                end
                if argc == 1 then
                    local arg = vim.fn.argv(0)
                    if arg == "" or vim.fn.isdirectory(arg) ~= 1 then
                        return
                    end
                end
                if vim.g.persistence_no_autoload then
                    return -- escape hatch: :lua vim.g.persistence_no_autoload = true
                end
                require("persistence").load()
            end,
        })

        -- persistence.nvim only writes the session on VimLeavePre, i.e. on a CLEAN
        -- `:qa`. If nvim is killed instead -- closing the terminal, killing the tmux
        -- pane, an ssh drop, a crash -- nothing is ever saved. Checkpoint as well.
        --
        -- The `need` guard has to be repeated here: persistence's own check lives in
        -- its VimLeavePre handler, while the public M.save() is an unconditional
        -- `mks!`. Calling it while sitting on the dashboard would overwrite a good
        -- session with an empty one.
        local function worth_saving()
            for _, b in ipairs(vim.api.nvim_list_bufs()) do
                local ft = vim.bo[b].filetype
                if
                    vim.bo[b].buftype == ""
                    and not vim.tbl_contains({ "gitcommit", "gitrebase", "jj" }, ft)
                    and vim.api.nvim_buf_get_name(b) ~= ""
                then
                    return true
                end
            end
            return false
        end
        local function save_now()
            local ok, p = pcall(require, "persistence")
            if ok and p.active() and worth_saving() then
                pcall(p.save)
            end
        end

        vim.api.nvim_create_autocmd({ "FocusLost", "VimSuspend" }, {
            group = vim.api.nvim_create_augroup("persistence_extra_save", { clear = true }),
            callback = save_now,
        })
        -- FocusLost does not fire if you kill the pane while nvim still has focus,
        -- so also checkpoint on a slow timer. A session is one small file.
        local timer = vim.uv.new_timer()
        if timer then
            timer:start(60000, 60000, vim.schedule_wrap(save_now))
        end
    end,
}
