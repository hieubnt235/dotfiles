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
