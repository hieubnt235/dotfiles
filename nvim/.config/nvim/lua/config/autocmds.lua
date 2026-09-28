-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- SVG preview, done the way snacks intends. snacks' PUBLIC api for drawing an image
-- programmatically is `Snacks.image.placement.new(buf, src, opts)` -- the same call its
-- own hover/picker/markdown use. So: keep ONE scratch buffer in a split, and draw the
-- image into it with a placement; refresh = clean the buffer's placements + new one.
-- (No opening the PNG as a file buffer, no BufReadCmd, no nuke -- those were the hacks.)
-- snacks rasterizes the SVG itself (via ImageMagick), so we just hand it the .svg path.
do
    local group = vim.api.nvim_create_augroup("svg_preview", { clear = true })
    local st = { buf = nil, win = nil, img = nil, src = nil }

    local function win_ok()
        return st.win and vim.api.nvim_win_is_valid(st.win)
    end

    -- make sure the scratch buffer + split window exist (reused across previews)
    local function ensure()
        if not (st.buf and vim.api.nvim_buf_is_valid(st.buf)) then
            st.buf = vim.api.nvim_create_buf(false, true) -- nofile scratch
            vim.bo[st.buf].bufhidden = "hide"
        end
        if not win_ok() then
            local from = vim.api.nvim_get_current_win()
            vim.cmd("botright split") -- horizontal (bottom)
            st.win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(st.win, st.buf)
            vim.wo[st.win].number = false
            vim.wo[st.win].relativenumber = false
            vim.wo[st.win].cursorline = false
            vim.wo[st.win].signcolumn = "no"
            pcall(vim.api.nvim_set_current_win, from) -- keep cursor in the text
        end
    end

    local function close()
        pcall(function()
            Snacks.image.placement.clean(st.buf)
        end)
        if win_ok() then
            pcall(vim.api.nvim_win_close, st.win, true)
        end
        st.win, st.img, st.src = nil, nil, nil
    end

    -- Minimum size (px, long edge). snacks never upscales an image that fits the
    -- window, so a tiny SVG shows tiny. We render it bigger when it's below this floor;
    -- normal/large SVGs are left at natural size (snacks fits them to the window).
    local MIN_PX = 400
    local dir = vim.fn.stdpath("cache") .. "/svg-preview"
    vim.fn.mkdir(dir, "p")
    local seq = 0
    local cur_png -- the one temp png currently on disk

    -- rasterize `src` to a UNIQUE png and return its path. The unique name is REQUIRED:
    -- snacks caches images by sha256(SOURCE PATH) (convert.lua), so a reused filename
    -- always returns the FIRST image (never switches). Scale UP only if the svg's long
    -- edge < MIN_PX.
    local function render(src)
        local zoom = 1
        local dims = vim.fn.system({ "magick", "identify", "-format", "%w %h", src }) -- magick optional
        local w, h = dims:match("^(%d+)%s+(%d+)")
        w, h = tonumber(w), tonumber(h)
        if w and h then
            local long = math.max(w, h)
            if long > 0 and long < MIN_PX then
                zoom = MIN_PX / long
            end
        end
        seq = seq + 1
        local out = dir .. "/p" .. seq .. ".png"
        vim.fn.system({ "rsvg-convert", "--zoom", string.format("%.4f", zoom), "-o", out, src })
        return vim.v.shell_error == 0 and out or nil
    end

    local function show(src)
        local out = render(src)
        if not out then
            return vim.notify("SVG render failed", vim.log.levels.ERROR, { title = "SVG preview" })
        end
        ensure()
        local P = Snacks.image.placement
        pcall(P.clean, st.buf) -- drop previous placement(s) (keeps image data on the terminal)
        if cur_png and cur_png ~= out then
            pcall(vim.fn.delete, cur_png) -- keep only ONE temp png on disk (no accumulation)
        end
        cur_png, st.src = out, src
        local ok, img = pcall(P.new, st.buf, out, { auto_resize = true })
        if ok then
            st.img = img
        else
            vim.notify("SVG preview failed:\n" .. tostring(img), vim.log.levels.ERROR, { title = "SVG preview" })
        end
    end

    local function preview()
        local src = vim.api.nvim_buf_get_name(0)
        if not src:lower():match("%.svg$") then
            return vim.notify("Not an SVG file", vim.log.levels.WARN, { title = "SVG preview" })
        end
        -- We rasterize with rsvg-convert (librsvg). Check before doing anything.
        if vim.fn.executable("rsvg-convert") == 0 then
            return vim.notify(
                "`rsvg-convert` not found -- install it:\n  sudo apt install librsvg2-bin",
                vim.log.levels.ERROR,
                { title = "SVG preview" }
            )
        end
        if win_ok() and st.src == src then -- already showing this file -> toggle off
            return close()
        end
        show(src)
    end

    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "svg",
        callback = function(ev)
            vim.keymap.set("n", "<leader>Ps", preview, { buffer = ev.buf, desc = "SVG preview" })
        end,
    })
    -- refresh on save, only if the preview pane is open
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        pattern = "*.svg",
        callback = function(ev)
            if win_ok() then
                show(vim.api.nvim_buf_get_name(ev.buf))
            end
        end,
    })

    -- clean the temp dir on exit
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function()
            pcall(vim.fn.delete, dir, "rf")
        end,
    })

    -- which-key group label for the <leader>P "Preview" namespace
    pcall(function()
        require("which-key").add({ { "<leader>P", group = "preview" } })
    end)
end

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
