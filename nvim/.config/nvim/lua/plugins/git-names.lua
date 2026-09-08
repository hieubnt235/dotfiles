-- <leader>g label convention: lowercase, with the owning plugin in parens.
-- The "Git " prefix is dropped -- the group is already called git.
--
-- These entries are defined by LazyVim as lazy `keys` specs, so they must be
-- overridden as keys specs too; a plain vim.keymap.set gets clobbered when lazy
-- loads the plugin. The ones LazyVim sets with vim.keymap.set are relabeled in
-- lua/config/keymaps.lua instead.
--
-- Case pairing: lowercase = light (snacks picker), UPPERCASE = heavy (full UI).
--   <leader>gd = diff view (diffview); hunk picker moved to <leader>ghd
return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "status (snacks)" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "stash (snacks)" },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = true })
        end,
        desc = "explorer (neo-tree)",
      },
    },
  },
  -- octo: unbind every <leader>g mapping. Origin/GitHub is a separate workflow,
  -- not part of the local git loop. Freeing gS also settles the collision where
  -- octo and snacks both claimed it -- snacks' stash now wins outright.
  {
    "pwntester/octo.nvim",
    keys = {
      { "<leader>gi", false },
      { "<leader>gI", false },
      { "<leader>gp", false },
      { "<leader>gP", false },
      { "<leader>gr", false },
      { "<leader>gS", false },
    },
  },
}
