-- neo-tree <-> system clipboard, like an IDE file tree (Linux: X11 + Wayland).
--
--   y / x (also on a visual selection)  stock neo-tree copy / cut, AND the files go
--       on the system clipboard -> Ctrl+V in Thunar, Nautilus, Dolphin, ... (a cut
--       moves there).
--   p   pastes what is on the SYSTEM clipboard into the folder under the cursor:
--       - files/folders copied or cut in a file manager (or y/x here): copied/moved
--       - an image (Flameshot, browser "Copy Image"): asks a name, saved as a file
--       - anything else (e.g. text you yanked): neo-tree's own clipboard, as stock.
--   The actual copy/move is neo-tree's stock paste (name-clash prompt, refresh):
--   system-clipboard files are just handed to it as its clipboard items.
--
-- Unsupported setups say so instead of silently doing less: Windows, macOS, an
-- unknown $XDG_SESSION_TYPE, or a missing xclip / wl-copy / wl-paste. y/x/p then
-- still do their stock neo-tree job.
--
-- Clipboard commands, formats and desktop detection follow oil.nvim
-- (lua/oil/clipboard.lua, MIT); image reading follows img-clip.nvim (MIT).

local TITLE = { title = "neo-tree clipboard" }
local FILES_GNOME = "x-special/gnome-copied-files" -- "copy|cut\nfile://..." (GTK file managers)
local FILES_URI = "text/uri-list" -- freedesktop standard list of file:// URIs
local KDE_CUT = "application/x-kde-cutselection" -- "1" next to a uri-list = it was a cut

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, TITLE)
end

-- The clipboard tool for this session, or nil + the reason it can't be used.
local function backend()
    if vim.fn.has("win32") == 1 then
        return nil, "System clipboard not supported on Windows"
    end
    if vim.fn.has("mac") == 1 then
        return nil, "System clipboard not supported on macOS"
    end
    local session = (vim.env.XDG_SESSION_TYPE or ""):lower()
    local b
    if session:find("wayland") then
        b = {
            set = { "wl-copy", "-t" }, -- + type
            get = { "wl-paste", "-n", "-t" }, -- + type
            types = { "wl-paste", "-l" },
            tools = { "wl-copy", "wl-paste" },
            package = "wl-clipboard",
        }
    elseif session:find("x11") then
        b = {
            set = { "xclip", "-i", "-selection", "clipboard", "-t" },
            get = { "xclip", "-o", "-selection", "clipboard", "-t" },
            types = { "xclip", "-o", "-selection", "clipboard", "-t", "TARGETS" },
            tools = { "xclip" },
            package = "xclip",
        }
    else
        return nil,
            ("System clipboard not supported: $XDG_SESSION_TYPE is '%s' (needs x11 or wayland)"):format(
                vim.env.XDG_SESSION_TYPE or "unset"
            )
    end
    for _, tool in ipairs(b.tools) do
        if vim.fn.executable(tool) == 0 then
            return nil, ("'%s' not found -- install %s to use the system clipboard"):format(tool, b.package)
        end
    end
    return b
end

-- Run a clipboard command; returns stdout (raw bytes) or nil.
local function run(cmd, stdin)
    local ok, res = pcall(function()
        -- xclip -i / wl-copy fork to keep serving the clipboard: give them no
        -- stdout/stderr pipes, or waiting would hang until the next copy elsewhere.
        local opts = stdin and { stdin = stdin, stdout = false, stderr = false } or { text = false }
        return vim.system(cmd, opts):wait(3000)
    end)
    if not ok or not res or res.code ~= 0 then
        return nil
    end
    return res.stdout or ""
end

-- Desktops whose file managers read the GNOME format, which can mark a cut:
-- oil.nvim's list (GNOME, Cinnamon, XFCE) plus the other GTK-family ones (Nautilus /
-- Caja / Nemo / Thunar / PCManFM / Pantheon Files). Everyone else (KDE, LXQt, tiling
-- WMs...) gets the freedesktop text/uri-list, which every Linux file manager reads --
-- but it has no "cut" flag, so there a cut pastes as a copy (the notice says so).
local GTK_DESKTOPS = { "gnome", "cinnamon", "xfce", "mate", "budgie", "pantheon", "unity", "lxde" }
local function gnome_like()
    local desktop = ((vim.env.XDG_CURRENT_DESKTOP or "") .. ":" .. (vim.env.XDG_SESSION_DESKTOP or "")):lower()
    for _, name in ipairs(GTK_DESKTOPS) do
        if desktop:find(name, 1, true) then
            return true
        end
    end
    return false
end

-- Put files on the system clipboard as a copy or a cut.
local function write_files(b, paths, action)
    local uris = vim.tbl_map(vim.uri_from_fname, paths)
    local type, data
    if gnome_like() then
        type, data = FILES_GNOME, action .. "\n" .. table.concat(uris, "\n")
    else
        type, data = FILES_URI, table.concat(uris, "\r\n") .. "\r\n"
    end
    if not run(vim.list_extend(vim.deepcopy(b.set), { type }), data) then
        return notify("Could not write to the system clipboard", vim.log.levels.ERROR)
    end
    local what = #paths == 1 and vim.fs.basename(paths[1]) or (#paths .. " items")
    local note = ""
    if action == "cut" and type == FILES_URI then
        note = " (this desktop's apps will paste it as a copy)"
    end
    notify(("%s %s to the system clipboard%s"):format(action == "cut" and "Cut" or "Copied", what, note))
end

-- Files on the system clipboard: paths + "copy"/"cut", or nil.
local function read_files(b, types)
    local raw, action
    if types[FILES_GNOME] then
        raw = run(vim.list_extend(vim.deepcopy(b.get), { FILES_GNOME }))
        if raw then
            local first = raw:match("^([^\n]*)")
            action = first == "cut" and "cut" or "copy"
        end
    elseif types[FILES_URI] then
        raw = run(vim.list_extend(vim.deepcopy(b.get), { FILES_URI }))
        local cut = types[KDE_CUT] and run(vim.list_extend(vim.deepcopy(b.get), { KDE_CUT }))
        action = cut and vim.trim(cut) == "1" and "cut" or "copy"
    end
    if not raw then
        return nil
    end
    local paths = {}
    for line in raw:gsub("%z", "\n"):gmatch("[^\r\n]+") do
        if line:match("^file://") then
            paths[#paths + 1] = vim.uri_to_fname(line)
        end
    end
    return #paths > 0 and paths or nil, action
end

-- The best image type on the clipboard ("image/png" first) and its extension.
local function image_type(types)
    if types["image/png"] then
        return "image/png", "png"
    end
    for t in pairs(types) do
        local ext = t:match("^image/(%w+)$")
        if ext then
            return t, ext == "jpeg" and "jpg" or ext
        end
    end
end

-- neo-tree's stock filesystem commands (required on use: this file is read at startup).
local stock = setmetatable({}, {
    __index = function(_, name)
        return require("neo-tree.sources.filesystem.commands")[name]
    end,
})

-- Hand files to neo-tree's own clipboard and run its stock paste.
local function paste_paths(state, paths, action)
    state.clipboard = {}
    local missing = {}
    for _, path in ipairs(paths) do
        local stat = vim.uv.fs_stat(path)
        if stat then
            state.clipboard[path] = {
                action = action,
                node = {
                    id = path,
                    name = vim.fs.basename(path),
                    path = path,
                    type = stat.type == "directory" and "directory" or "file",
                },
            }
        else
            missing[#missing + 1] = path
        end
    end
    if #missing > 0 then
        notify(
            "Skipped (no longer exists -- moved by an earlier cut?):\n" .. table.concat(missing, "\n"),
            vim.log.levels.WARN
        )
    end
    if next(state.clipboard) then
        stock.paste_from_clipboard(state)
    end
end

-- The folder under the cursor: the directory itself, or a file's parent.
local function target_folder(state)
    local node = state.tree:get_node()
    if not node or not node.path then
        return nil
    end
    return node.type == "directory" and node.path or vim.fs.dirname(node.path)
end

-- Write the clipboard image straight into the folder under the cursor, under a
-- name you choose (asks again if it exists -- never overwrites), then reveal it.
local function paste_image(state, b, type, ext)
    local folder = target_folder(state)
    if not folder then
        return notify("Put the cursor on a folder or file first", vim.log.levels.WARN)
    end
    local data = run(vim.list_extend(vim.deepcopy(b.get), { type }))
    if not data or #data == 0 then
        return notify("Could not read the image from the system clipboard", vim.log.levels.ERROR)
    end
    local function ask(default)
        vim.ui.input({ prompt = "Image name: ", default = default }, function(name)
            name = name and vim.trim(name) or ""
            if name == "" then
                return
            end
            if name:find("/") then
                notify("A name, not a path: no '/'", vim.log.levels.WARN)
                return ask(name:gsub("/", ""))
            end
            if vim.fn.fnamemodify(name, ":e") == "" then
                name = name .. "." .. ext
            end
            local path = folder .. "/" .. name
            if vim.uv.fs_stat(path) then
                notify(name .. " already exists -- choose another name", vim.log.levels.WARN)
                return ask(vim.fn.fnamemodify(name, ":r"))
            end
            local f, err = io.open(path, "wb")
            if not f then
                return notify("Could not write " .. path .. ": " .. tostring(err), vim.log.levels.ERROR)
            end
            f:write(data)
            f:close()
            require("neo-tree.sources.filesystem").navigate(state, nil, path)
        end)
    end
    ask(os.date("%Y-%m-%d-%H-%M-%S"))
end

-- y / x: stock neo-tree, then mirror its clipboard onto the system clipboard.
local function mirror(state)
    local paths, all_cut = {}, true
    for _, item in pairs(state.clipboard or {}) do
        paths[#paths + 1] = item.node.path
        all_cut = all_cut and item.action == "cut"
    end
    if #paths == 0 then
        return
    end
    local b, err = backend()
    if not b then
        return notify(err .. " -- copied in neo-tree only", vim.log.levels.WARN)
    end
    write_files(b, paths, all_cut and "cut" or "copy")
end

local commands = {
    copy_to_clipboard = function(state)
        stock.copy_to_clipboard(state)
        mirror(state)
    end,
    copy_to_clipboard_visual = function(state, nodes)
        stock.copy_to_clipboard_visual(state, nodes)
        mirror(state)
    end,
    cut_to_clipboard = function(state)
        stock.cut_to_clipboard(state)
        mirror(state)
    end,
    cut_to_clipboard_visual = function(state, nodes)
        stock.cut_to_clipboard_visual(state, nodes)
        mirror(state)
    end,
    paste_from_clipboard = function(state)
        local b, err = backend()
        if not b then
            notify(err .. " -- pasting neo-tree's own clipboard", vim.log.levels.WARN)
            return stock.paste_from_clipboard(state)
        end
        local types = {}
        for t in (run(b.types) or ""):gmatch("[^\r\n]+") do
            types[vim.trim(t)] = true
        end
        local paths, action = read_files(b, types)
        if paths then
            return paste_paths(state, paths, action)
        end
        local img, ext = image_type(types)
        if img then
            return paste_image(state, b, img, ext)
        end
        if next(state.clipboard or {}) then
            return stock.paste_from_clipboard(state)
        end
        notify("Nothing to paste: no files or image on the system clipboard", vim.log.levels.WARN)
    end,
}

return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        opts = function(_, opts)
            opts.filesystem = opts.filesystem or {}
            opts.filesystem.commands = vim.tbl_extend("force", opts.filesystem.commands or {}, commands)
        end,
    },
}
