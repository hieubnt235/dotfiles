-- Move the code Outline panel from the RIGHT edge (LazyVim default) to the LEFT
-- sidebar, then order the left panel as Filesystem / Outline / Buffers / Git with
-- short titles. Also set default sidebar widths + the Alt+HJKL resize behavior.
return {
    "folke/edgy.nvim",
    opts = function(_, opts)
        opts.left = opts.left or {}
        opts.right = opts.right or {}
        for i = #opts.right, 1, -1 do
            if opts.right[i].ft == "Outline" then
                table.insert(opts.left, table.remove(opts.right, i))
            end
        end

        -- Left-panel ORDER + short TITLES only. This just rearranges/renames the
        -- sidebar entries LazyVim already created; it does NOT touch the
        -- resize/persist/animate behavior below.
        --   Order (top -> bottom): Filesystem, Outline, Buffers
        --   Titles: shorten LazyVim's long "Neo-Tree Buffers" etc. to one word.
        local function kind(item)
            if item.ft == "Outline" then
                return "outline"
            end
            local t = tostring(item.title or ""):lower()
            if t:find("file") then
                return "files"
            end
            if t:find("buffer") then
                return "buffers"
            end
            if t:find("git") then
                return "git"
            end
        end
        local short_title = { files = "Files", outline = "Outline", buffers = "Buffers", git = "Git" }
        -- "git" stays in short_title/kind so the Git panel is still CLASSIFIED and
        -- thus excluded from `rest`; leaving it out of `want` drops it entirely.
        local want = { "files", "outline", "buffers" }
        local matched, rest = {}, {}
        for _, item in ipairs(opts.left) do
            local k = kind(item)
            if k then
                item.title = short_title[k]
                matched[k] = item
            else
                rest[#rest + 1] = item -- keep any other panels (e.g. Neotest) as-is
            end
        end
        local ordered = {}
        for _, k in ipairs(want) do
            if matched[k] then
                ordered[#ordered + 1] = matched[k]
            end
        end
        vim.list_extend(ordered, rest)
        opts.left = ordered

        -- Default panel sizes -- the size each panel STARTS at on a fresh nvim.
        --   LEFT   = file/git/buffer trees + Outline (40 columns wide)
        --   RIGHT  = AI / Claude panel (0.3 = 30% of screen width)
        --   BOTTOM = terminal (0.3 = 30% of screen height)
        -- Resize live with Alt+HJKL (below); that size now persists across toggle
        -- for the session. These values are only the starting point after restart.
        -- Show/hide panels instantly on toggle -- no slide-in animation.
        opts.animate = vim.tbl_extend("force", opts.animate or {}, { enabled = false })

        opts.options = opts.options or {}
        opts.options.left = vim.tbl_extend("force", opts.options.left or {}, { size = 0.2 })
        opts.options.right = vim.tbl_extend("force", opts.options.right or {}, { size = 0.3 })
        opts.options.bottom = vim.tbl_extend("force", opts.options.bottom or {}, { size = 0.3 })

        -- Make terminals follow their SLOT size (the single knob: options.<edge>.size
        -- above), exactly like neo-tree / outline / claude do. LazyVim pins a PER-VIEW
        -- size on the terminal entries (size = { height = 0.4 }), and a per-view size
        -- OVERRIDES the slot default -- that's why changing options.bottom.size didn't
        -- move the <C-/> terminal, while the side panels (no per-view size) tracked
        -- their slot fine. We drop the pin on every edge so a terminal inherits
        -- whichever slot it docks in. One value per edge controls everything.
        for _, edge in ipairs({ opts.left, opts.right, opts.bottom, opts.top }) do
            for _, e in ipairs(edge or {}) do
                if e.ft == "snacks_terminal" or e.ft == "terminal" or e.ft == "toggleterm" then
                    e.size = nil
                end
            end
        end

        -- Fix edgy's "cached shrink" bug. Two root causes in edgy:
        --   1. Its resize (window.lua:212) bases each step on a STORED value that
        --      keeps sinking BELOW the visible floor -- so once you hit the
        --      smallest size, extra shrinks bank a hidden deficit you must "pay
        --      back" before anything grows again.
        --   2. A panel's shared "thickness" (a left/right panel's WIDTH, a bottom
        --      panel's HEIGHT) is the MAX of every stacked window's stored size
        --      (edgebar.lua:246). Resizing only the focused window leaves a
        --      sibling pinning the panel, so nothing visibly changes.
        -- We base each step on the window's ACTUAL current size (which edgy clamps
        -- to the floor), and for the shared axis we write it to EVERY window in the
        -- edgebar. So shrinks self-heal at the floor and the next grow takes effect
        -- immediately, with no sibling left pinning the size.
        -- Also PERSIST the size across toggle. edgy stores a resize only in the
        -- window-local `vim.w[win].edgy_*`, which dies when the window closes -- so
        -- on reopen it falls back to the default. But the edgebar and its view
        -- objects live for the whole session, so we also write the size there:
        -- `bar.size` is the shared thickness floor (read on every reopen) and
        -- `view.size[axis]` is each window's per-axis default. (A full nvim restart
        -- still starts from the configured defaults below -- that's what sessions
        -- are for.)
        -- Minimum panel size, so a shrink can't collapse a panel into a useless
        -- sliver (CLion-style: a divider has a floor; to hide a panel you TOGGLE
        -- it -- <leader>e, or q / <c-q> inside the panel -- not shrink it to zero).
        local MIN = { width = 10, height = 3 }
        local function step(win, axis, delta)
            pcall(function()
                local bar = win.view.edgebar
                local short = bar.vertical and "width" or "height" -- the shared "thickness" axis
                local get = axis == "width" and vim.api.nvim_win_get_width or vim.api.nvim_win_get_height
                local target = math.max((get(win.win) or 1) + delta, MIN[axis])
                if axis == short then
                    bar.size = target -- new thickness floor, survives toggle
                    for _, w in ipairs(bar.wins) do
                        w.view.size[axis] = target
                        vim.w[w.win]["edgy_" .. axis] = target
                    end
                else
                    win.view.size[axis] = target
                    vim.w[win.win]["edgy_" .. axis] = target
                end
                require("edgy.layout").update()
            end)
        end
        -- Resize panels with Alt+HJKL. These edgy `opts.keys` are BUFFER-LOCAL, so
        -- they only apply while focused inside an edgy panel and route through the
        -- fixed `step` above. (The redundant global Alt+h/l scroll was removed from
        -- options.lua, so there's no conflict in normal files.)
        --   H = narrower, L = wider, J = shorter, K = taller
        opts.keys = opts.keys or {}
        opts.keys["<A-l>"] = function(win)
            step(win, "width", 2)
        end
        opts.keys["<A-h>"] = function(win)
            step(win, "width", -2)
        end
        opts.keys["<A-k>"] = function(win)
            step(win, "height", 2)
        end
        opts.keys["<A-j>"] = function(win)
            step(win, "height", -2)
        end
    end,
}
