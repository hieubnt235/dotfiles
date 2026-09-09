-- Layer 3: multi-file side-by-side diffs, file/branch history, and 3-way merge
-- resolution. Independent of neogit/gitsigns/snacks -- it talks to git directly.
-- snacks pickers cover browsing commits/status with a UNIFIED preview; diffview
-- is for the CLion-style "compare across all files in splits" + merge tool.
--
-- Tracking dlyongemallo/diffview-plus.nvim, NOT sindrets/diffview.nvim.
-- Upstream is dead: last commit 2024-06-13, 35 open bug reports incl. a memory
-- leak (#613), a hang in FileHistory (#552), and a crash during merge (#615).
-- The fork is the same codebase with the backlog cleared: 143 fix commits,
-- 70 test specs (upstream had 2), CI, and 0 open bugs. Same `diffview` lua
-- module + same commands, so Neogit's integration keeps working untouched.
return {
  {
    "dlyongemallo/diffview-plus.nvim",
    -- The plugin dir is `diffview-plus.nvim` but the lua module is still
    -- `diffview`, which lazy.nvim cannot guess. Without this, `opts` below is
    -- silently never applied.
    main = "diffview",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      -- Fork-only, not in dead upstream: compare two arbitrary paths with no
      -- git involved. DiffFiles = two files, DiffDirs = two directories,
      -- MergeFiles = manual 3-way merge of unrelated files.
      "DiffviewDiffFiles",
      "DiffviewDiffDirs",
      "DiffviewMergeFiles",
      "DiffviewToggle",
    },
    opts = {
        -- The fork restores Diffview views from a :mksession sidecar
        -- (~/.local/state/nvim/sessions/<session>.vim.diffview.json). On
        -- SessionLoadPost it wipes diffview:// buffers and sets buflisted=false on
        -- every LOCAL file a view had opened ("created_paths"). If the file you quit
        -- on was one of those, it comes back UNLISTED: missing from the bufferline,
        -- neo-tree opens a different file instead, and nothing attaches to it --
        -- session.lua's own comment says it "drops into [No Name]". `:bd` + reopen
        -- is the only way out. Upstream sindrets/diffview.nvim has no session module
        -- at all, so this behaviour arrived with the fork. We use persistence.nvim
        -- for sessions and do not need diffview tabs restored.
        restore_session = false,
        -- Label each diff window with the revision it holds, so "which side is
        -- FROM and which is TO" is never a guess. Native option
        -- (|diffview-config-view.x.winbar_info|), off by default for these two
        -- views; `merge_tool` already ships with it on.
        view = {
            default = { winbar_info = true },
            file_history = { winbar_info = true },
        },
        -- `q` closes the view. This is the plugin's OWN convention extended, not
        -- an override: it already binds q -> actions.close in its option, help and
        -- commit-log panels; those are simply the only panels upstream bothered to
        -- bind. Same key, in the two places it left unbound.
        --
        -- DiffviewClose rather than `:q` or actions.close: a diffview tab is
        -- several windows, and tearing one down leaves orphaned windows and stale
        -- state (see the <leader>gd note below). DiffviewClose is the full
        -- teardown -- the same one DiffviewToggle calls -- so <leader>gd stays in
        -- sync and reopens cleanly afterwards.
        --
        -- Scoped to diffview's own buffers, so `q` (record macro) is untouched
        -- everywhere else.
        keymaps = {
            view = {
                { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
            },
            file_panel = {
                { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
            },
            file_history_panel = {
                { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
            },
        },
    },
    keys = {
      -- Compare: working tree vs HEAD (prompt-free). Pass a ref in the cmdline
      -- for others, e.g. :DiffviewOpen main..HEAD  or  :DiffviewOpen HEAD~3
      --
      -- CONFLICTS: with a merge/rebase in progress this same command opens the
      -- 3-way merge tool automatically. In a conflicted file:
      --   ]x / [x            jump between conflicts
      --   <leader>co / ct    take OURS / THEIRS
      --   <leader>cb / ca    take BASE / ALL
      -- REVIEW: in the file panel, `H` toggles hiding files you've marked
      -- reviewed -- useful for working through a big changeset.
      -- TOGGLE, not open/close. diffview binds no close key in the main view or
      -- file panel (only in the option/help/commit-log sub-panels), and `:q`
      -- tears down one window of a multi-window tab, leaving orphaned windows
      -- and stale state. DiffviewToggle is the fork's open-or-close-in-one.
      -- Top-level shortcut for the same toggle, so the common case is one key.
      -- The snacks hunk picker lives at <leader>ghd (the hunk group) instead.
      { "<leader>gd", "<cmd>DiffviewToggle<cr>", desc = "toggle diff (diffview)" },
      -- <leader>gD<x> = pick the FROM side, then a branch picker gives the TO
      -- side. <leader>gd is the shortcut for the common case (HEAD, no picker).
      --   Dw  working tree -> branch    :DiffviewOpen <ref>
      --   Ds  staged       -> branch    :DiffviewOpen --staged <ref>
      --   Dh  HEAD         -> branch    :DiffviewOpen HEAD..<ref>
      --   Db  branch       -> branch    :DiffviewOpen <a>..<b>  (two pickers)
      {
        "<leader>gDw",
        function() require("diffview_from").pick("working") end,
        desc = "working tree -> branch/commit (diffview)",
      },
      {
        "<leader>gDs",
        function() require("diffview_from").pick("staged") end,
        desc = "staged -> branch/commit (diffview)",
      },
      {
        "<leader>gDh",
        function() require("diffview_from").pick("head") end,
        desc = "head -> branch/commit (diffview)",
      },
      {
        "<leader>gDb",
        function() require("diffview_from").pick_two() end,
        desc = "branch/commit -> branch/commit (diffview)",
      },
      -- History
      { "<leader>gLb", "<cmd>DiffviewFileHistory<cr>", desc = "whole branch (diffview)" },
      { "<leader>gLf", "<cmd>DiffviewFileHistory %<cr>", desc = "current file (diffview)" },
    },
  },
  -- LazyVim binds <leader>gd to snacks' git_diff picker and <leader>gD to the
  -- same picker with base=origin. Release both: gd is diffview now, and gD is
  -- gone entirely (the hunk picker is <leader>ghd).
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>gd", false },
      { "<leader>gD", false },
    },
  },
  -- which-key group label
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>gD", group = "diff from-to" },
        { "<leader>gl", group = "log" },
        { "<leader>gL", group = "log diff" },
      },
    },
  },
}
