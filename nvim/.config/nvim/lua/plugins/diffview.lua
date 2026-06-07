-- Layer 3: multi-file side-by-side diffs, file/branch history, and 3-way merge
-- resolution. Independent of lazygit/gitsigns/snacks -- it talks to git directly.
-- snacks pickers cover browsing commits/status with a UNIFIED preview; diffview
-- is for the CLion-style "compare across all files in splits" + merge tool.
return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
    },
    opts = {},
    keys = {
      -- Compare: working tree vs HEAD (prompts-free). Pass a ref in the cmdline
      -- for others, e.g. :DiffviewOpen main..HEAD  or  :DiffviewOpen HEAD~3
      { "<leader>gvv", "<cmd>DiffviewOpen<cr>", desc = "Open (working tree vs HEAD)" },
      { "<leader>gvc", "<cmd>DiffviewClose<cr>", desc = "Close" },
      -- History
      { "<leader>gvf", "<cmd>DiffviewFileHistory %<cr>", desc = "History: current file" },
      { "<leader>gvF", "<cmd>DiffviewFileHistory<cr>", desc = "History: whole branch" },
      -- Panel toggle while a diffview is open
      { "<leader>gvt", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle file panel" },
    },
  },
  -- which-key group label
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>gv", group = "diffview" },
      },
    },
  },
}
