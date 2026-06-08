-- File tree = neo-tree (set via vim.g.lazyvim_explorer in options.lua).
-- (snacks picker / find / grep config lives in snacks.lua.)
-- Show hidden (dotfiles) AND gitignored files by default. Toggle them off
-- from inside the tree with `H` (neo-tree's toggle_hidden).

-- Access-level styling for the tree -- INDEPENDENT of git color. Two orthogonal
-- things drive how a name looks:
--   * git status = the COLOR (modified -> yellow, etc.). Left untouched.
--   * access level = MODIFIERS layered on top of whatever that color is:
--       hidden (name starts ".") -> DIM + ITALIC  (most "no touch": libs, IDE/tool cfg)
--       gitignored (non-dotfile) -> DIM           (background: local docs/scratch)
--       normal                   -> nothing       (bright, active code)
-- So a *modified dotfile* keeps git's yellow, just dimmed + italic -- git never
-- removes the access cue. neo-tree's built-in order checks "gitignored" BEFORE
-- "dotfile", so .claude (which is both) would otherwise lose its italic; this
-- wrapper makes the dotfile/italic decision purely from the name, so hidden
-- always wins regardless of git state.
local function patch_access_styling()
    local ok, fc = pcall(require, "neo-tree.sources.filesystem.components")
    if not ok or fc.__access_patched then
        return
    end
    fc.__access_patched = true
    local stock_name = fc.name

    -- Lowered brightness for hidden/ignored names (normal files stay full = 1).
    -- How much of the real color is kept: 1 = full color (no blur), 0 = invisible
    -- (full bg). LOWER = more blur. <-- edit this number.
    local LOW_BRIGHTNESS = 0.5
    LOW_BRIGHTNESS = math.min(1, math.max(0, LOW_BRIGHTNESS)) -- clamp to a safe 0..1

    -- Blend two 0xRRGGBB ints; `a` = weight of fg.
    local function blend(fg, bg, a)
        local function mix(shift)
            local x = math.floor(fg / shift) % 256
            local y = math.floor(bg / shift) % 256
            return math.floor(x * a + y * (1 - a) + 0.5)
        end
        return mix(65536) * 65536 + mix(256) * 256 + mix(1)
    end

    -- Perf: this runs per visible node on every tree render, but the only thing
    -- that actually changes is the colorscheme. So cache everything keyed by color
    -- and wipe the cache on :colorscheme. Steady-state cost per dimmed node is a
    -- couple of table lookups; nvim_get_hl / nvim_set_hl run once per color, ever.
    local cache = {} -- resolved hl attrs ("g:fg") + defined dynamic groups ("d:NAME")
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            cache = {}
        end,
    })
    local function attr(group, key)
        local ck = group .. ":" .. key
        local v = cache[ck]
        if v == nil then
            v = (vim.api.nvim_get_hl(0, { name = group, link = false }) or {})[key] or false
            cache[ck] = v
        end
        return v or nil -- `false` = looked up and was unset
    end

    -- "hidden" PROPAGATES down a dot-folder (CLion-style: parent hidden -> all
    -- contents hidden). A node is hidden if its OWN name starts with ".", OR any
    -- ancestor folder does. We test the path RELATIVE to the tree root, so it only
    -- fires for dot-dirs shown *inside* the tree -- root neo-tree directly at
    -- ~/.config/nvim and you're working there, so nothing gets dimmed.
    local function is_hidden(node, state)
        if (node.name or ""):sub(1, 1) == "." then
            return true
        end
        local root = state.path or ""
        local p = node.path or (node.get_id and node:get_id()) or ""
        if root ~= "" and p:sub(1, #root) == root then
            p = p:sub(#root + 1) -- keep only the in-tree portion of the path
        end
        return p:find("/%.[^/]") ~= nil -- any "/.something" ancestor segment = hidden
    end

    -- "ignored" also PROPAGATES: a gitignored FOLDER dims all its contents. git
    -- collapses ignored dirs (it flags `build/`, not every file inside), so the
    -- children don't carry the gitignored flag themselves -- we walk the parent
    -- chain in the tree and check each ancestor. Not cached: git status can change
    -- between renders, and the walk is just in-memory table lookups.
    local function is_ignored(node, state)
        local tree = state.tree
        local n = node
        while n do
            if n.filtered_by and n.filtered_by.gitignored then
                return true
            end
            if not (tree and n.get_parent_id) then
                break
            end
            local pid = n:get_parent_id()
            n = pid and tree:get_node(pid) or nil
        end
        return false
    end

    fc.name = function(config, node, state)
        local res = stock_name(config, node, state)
        local hidden = is_hidden(node, state)
        local ignored = is_ignored(node, state)
        if not (hidden or ignored) then
            return res -- active file: keep its git/normal color, bright + upright
        end
        -- Base color = the color this file would have IGNORING access level: its
        -- git CHANGE color if git colored it (modified/added/...), else the plain
        -- file/dir text color. We skip git's "ignored" highlight on purpose -- that
        -- is itself an access marker, not a real status color, so it shouldn't seed
        -- the blur (otherwise gitignored files would dim twice / go gray).
        local base
        local gok, git = pcall(state.components.git_status, {}, node, state)
        if gok and git and git.highlight and git.highlight ~= "NeoTreeGitIgnored" then
            base = attr(git.highlight, "fg")
        end
        base = base
            or attr(node.type == "directory" and "NeoTreeDirectoryName" or "NeoTreeFileName", "fg")
            or attr("Normal", "fg")
            or 0xdcd7ba
        local bg = attr("Normal", "bg") or 0x1f1f28
        -- One highlight per (color, italic) combo, defined once and reused.
        local dim = blend(base, bg, LOW_BRIGHTNESS)
        local key = string.format("NeoTreeAccess_%06x_%s", dim, hidden and "i" or "u")
        if not cache["d:" .. key] then
            vim.api.nvim_set_hl(0, key, { fg = dim, italic = hidden })
            cache["d:" .. key] = true
        end
        res.highlight = key
        return res
    end
end

return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        opts = function(_, opts)
            patch_access_styling()
            -- Keep file-type ICONS at full color for hidden/ignored files; only the
            -- NAME carries the dim/italic access cue (see patch_access_styling).
            opts.default_component_configs = vim.tbl_deep_extend("force", opts.default_component_configs or {}, {
                icon = { use_filtered_colors = false },
            })
            opts.filesystem = vim.tbl_deep_extend("force", opts.filesystem or {}, {
                -- `visible = true` shows hidden (dotfiles) + gitignored by default.
                -- `H` (toggle_hidden) flips THIS flag, so the toggle works. Do NOT
                -- also set hide_dotfiles/hide_gitignored = false: those force the
                -- files visible regardless of `visible`, breaking the `H` toggle.
                filtered_items = { visible = true },
            })
            -- Directory-scoped search (CLion's "find in folder"): cursor on a folder
            -- (or any file inside it), then F = fuzzy find-files, G = live grep in it.
            opts.filesystem.window = vim.tbl_deep_extend("force", opts.filesystem.window or {}, {
                mappings = { ["F"] = "find_in_dir", ["G"] = "grep_in_dir" },
            })
            opts.filesystem.commands = vim.tbl_deep_extend("force", opts.filesystem.commands or {}, {
                find_in_dir = function(state)
                    local node = state.tree:get_node()
                    local path = node:get_id()
                    local dir = node.type == "directory" and path or vim.fn.fnamemodify(path, ":h")
                    require("snacks").picker.files({ cwd = dir })
                end,
                grep_in_dir = function(state)
                    local node = state.tree:get_node()
                    local path = node:get_id()
                    local dir = node.type == "directory" and path or vim.fn.fnamemodify(path, ":h")
                    require("snacks").picker.grep({ cwd = dir })
                end,
            })
        end,
    },
}
