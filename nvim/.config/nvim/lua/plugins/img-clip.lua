-- Paste a clipboard image (e.g. a Flameshot capture) into the current file: saves it
-- as a .png and inserts the link -- `![](assets/....png)` in markdown. snacks.image
-- then shows it inline. Uses xclip on X11; only works when nvim runs on the machine
-- that owns the clipboard (not over ssh). It asks "File name:" -- Enter on the empty
-- prompt uses the date-time name.
--
-- Drag and drop: drop an image file onto the terminal in NORMAL mode and it's
-- copied into assets/ and linked the same way (in insert mode a drop stays plain
-- text -- img-clip's default, so pasting a path as text still works).
return {
    {
        "HakonHarnes/img-clip.nvim",
        -- Not lazy on keys/cmd: drag and drop hooks vim.paste in the plugin's
        -- plugin/ file, which only runs once the plugin is loaded.
        event = "VeryLazy",
        opts = {
            default = {
                -- Save next to the file being edited (default is relative to cwd), so
                -- the inserted link resolves from the .md file itself, wherever it lives.
                relative_to_current_file = true,
                -- A dropped file is copied into assets/ (default links to wherever it
                -- was, e.g. ~/Pictures, which breaks once the repo is pushed).
                copy_images = true,
            },
        },
        keys = {
            { "<leader>P", "<cmd>PasteImage<cr>", desc = "Paste Image" },
        },
    },
}
