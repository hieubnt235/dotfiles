-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Clear vim.lsp.log at 1 GB.
--
-- Neovim already notices the file getting huge -- vim/lsp/log.lua:117 checks
-- `size > 1e9` -- but all it does is print a warning, so the file just keeps
-- growing. Nothing rotates it, and every line a server writes to stderr is
-- recorded as an ERROR entry regardless of log level, so a chatty server (clangd
-- logs one line per request at its default --log=info) grows it fast.
--
-- Same threshold, but clear instead of warn. Everything else stays default: no
-- server log levels overridden, no truncation during normal use.
do
    local CAP = 1e9 -- matches vim/lsp/log.lua:117
    local ok, path = pcall(vim.lsp.log.get_filename)
    if ok and path then
        local st = vim.uv.fs_stat(path)
        if st and st.size > CAP then
            -- "w" truncates. Servers open the log in append mode, so a running
            -- instance keeps writing correctly at the new end of file.
            local f = io.open(path, "w")
            if f then
                f:close()
            end
        end
    end
end

-- Autosave, CLion-style (its defaults: save when switching away, and when idle
-- 15 s). Every changed file is written when nvim loses focus (another app or
-- tmux pane -- needs tmux `focus-events on`, which is set), when you leave a
-- buffer, and IDLE_MS after the last edit.
--   * No formatting: the save runs with LazyVim's per-buffer switch
--     vim.b.autoformat = false, so oxfmt runs only on an explicit :w.
--   * Never overwrites a file that changed on disk (git checkout, CLion, a
--     build) since nvim read or wrote it. A plain `silent! update` there BLOCKS
--     on "Do you really want to write to it (y/n)?" -- from a timer that is a
--     surprise frozen prompt (auto-save.nvim has exactly this bug). Such a file
--     is skipped; an explicit :w still asks.
--   * Never writes from the cmdline, a prompt, or operator-pending; the idle
--     timer just retries.
do
    local IDLE_MS = 15000
    local group = vim.api.nvim_create_augroup("autosave", { clear = true })

    -- The file's mtime on disk, or nil when it doesn't exist (yet).
    local function mtime(name)
        local st = vim.uv.fs_stat(name)
        return st and (st.mtime.sec .. "." .. st.mtime.nsec)
    end

    -- Remember the mtime nvim last saw for each buffer's file.
    local function remember(buf)
        vim.b[buf].autosave_mtime = mtime(vim.api.nvim_buf_get_name(buf))
    end
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "FileChangedShellPost" }, {
        group = group,
        callback = function(ev)
            remember(ev.buf)
        end,
    })
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do -- files opened before VeryLazy
        if vim.api.nvim_buf_is_loaded(buf) then
            remember(buf)
        end
    end

    -- Write every changed file buffer. Returns false when now is not a safe
    -- moment to write (the caller retries later).
    local function save_all()
        local m = vim.api.nvim_get_mode()
        if m.blocking or m.mode:find("^[cr]") or m.mode:find("^no") then
            return false
        end
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local bo, name = vim.bo[buf], vim.api.nvim_buf_get_name(buf)
            if
                bo.modified
                and bo.buftype == ""
                and bo.modifiable
                and not bo.readonly
                and name ~= ""
                and mtime(name) == vim.b[buf].autosave_mtime
            then
                local prev = vim.b[buf].autoformat
                vim.b[buf].autoformat = false
                -- pcall: the switch is restored no matter what, so an explicit :w
                -- always formats exactly as before.
                pcall(vim.api.nvim_buf_call, buf, function()
                    vim.cmd("silent! lockmarks update") -- lockmarks: keep '[ '] marks
                end)
                vim.b[buf].autoformat = prev
            end
        end
        return true
    end

    vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
        group = group,
        callback = function()
            vim.schedule(save_all) -- after the focus/buffer switch completes
        end,
    })

    local timer = assert(vim.uv.new_timer())
    local function arm()
        timer:stop()
        timer:start(
            IDLE_MS,
            0,
            vim.schedule_wrap(function()
                if not save_all() then
                    arm()
                end
            end)
        )
    end
    -- Idle = no change in the CURRENT buffer for IDLE_MS; each pass saves every
    -- changed buffer. A file changed only in the background (not the current
    -- buffer) is saved at the next pass / focus-lost / buffer-leave. (Neovim has
    -- no event for that: BufModifiedSet fires only for the current buffer --
    -- checked.)
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP" }, {
        group = group,
        callback = arm,
    })
end

-- dadbod-ui drawer: give <C-j>/<C-k> back to window navigation.
--
-- vim-dadbod-ui's ftplugin/dbui.vim maps them buffer-locally to "jump to
-- last/first sibling", which shadows LazyVim's <C-w>j/<C-w>k, so you could not
-- leave the drawer up/down (<C-h>/<C-l> were never touched, so those worked).
-- Our FileType autocmd runs after the ftplugin, so these buffer maps win.
-- J/K (prev/next sibling) and <C-p>/<C-n> (parent/child) are still there.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("dbui_window_nav", { clear = true }),
    pattern = "dbui",
    callback = function(ev)
        vim.keymap.set("n", "<C-j>", "<C-w>j", { buffer = ev.buf, desc = "Go to Lower Window" })
        vim.keymap.set("n", "<C-k>", "<C-w>k", { buffer = ev.buf, desc = "Go to Upper Window" })
    end,
})
