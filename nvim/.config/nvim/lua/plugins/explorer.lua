-- File tree = neo-tree (set via vim.g.lazyvim_explorer in options.lua).
-- (snacks picker / find / grep config lives in snacks.lua.)
-- Show hidden (dotfiles) AND gitignored files by default. Toggle them off
-- from inside the tree with `H` (neo-tree's toggle_hidden).
return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        opts = {
            filesystem = {
                filtered_items = {
                    -- `visible = true` shows hidden (dotfiles) + gitignored by
                    -- default. `H` (toggle_hidden) flips THIS flag, so the toggle
                    -- works. Do NOT also set hide_dotfiles/hide_gitignored = false:
                    -- those force the files visible regardless of `visible`, which
                    -- breaks the `H` toggle (flag flips but files stay).
                    visible = true,
                },
                -- Directory-scoped search (CLion's "find in folder"): put the
                -- cursor on a folder (or any file inside it) in the tree, then
                -- F = fuzzy find-files in that folder, G = live grep in it.
                window = {
                    mappings = {
                        ["F"] = "find_in_dir",
                        ["G"] = "grep_in_dir",
                    },
                },
                commands = {
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
                },
            },
        },
    },
}
