return {
  "lewis6991/gitsigns.nvim",
  -- <leader>gh is the HUNK group -- nothing else.
  --
  -- LazyVim binds <leader>ghp to preview_hunk_INLINE. We prefer:
  --   <leader>ghp = preview_hunk        (floating popup, CLion-style)
  --   <leader>ghi = preview_hunk_inline (inline)
  --
  -- Dropped from the group:
  --   ghb / ghB  blame     -- gb / gB already do this (see config/keymaps.lua)
  --   ghD        diffthis "~"
  -- Repointed:
  --   ghd        was gitsigns diffthis (1 file vs index, native vim diff mode).
  --              It silently no-ops when the window is already in diff mode, and
  --              its BufHidden cleanup only fires when no other diff window is
  --              open -- otherwise your buffer stays stuck in 'diff'. Now it is
  --              snacks' hunk picker, same as <leader>gd.
  --
  -- on_attach maps are buffer-local, so we wrap LazyVim's on_attach and run
  -- ours AFTER it (later buffer-local maps override earlier ones).
  opts = function(_, opts)
    local orig = opts.on_attach
    opts.on_attach = function(buffer)
      if orig then
        orig(buffer)
      end
      local gs = require("gitsigns")
      local function map(lhs, rhs, desc, mode)
        vim.keymap.set(mode or "n", lhs, rhs, { buffer = buffer, desc = desc })
      end
      local function unmap(lhs)
        pcall(vim.keymap.del, "n", lhs, { buffer = buffer })
      end

      map("<leader>ghp", gs.preview_hunk, "preview hunk popup (gitsigns)")
      map("<leader>ghi", gs.preview_hunk_inline, "preview hunk inline (gitsigns)")
      map("<leader>ghd", function()
        Snacks.picker.git_diff()
      end, "diff hunk (snacks)")

      -- Same behaviour as LazyVim's ]h / [h: fall back to vim's native ]c / [c
      -- when the window is in diff mode, since gitsigns' hunk data does not
      -- apply there.
      map("<leader>ghn", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "next hunk (gitsigns)")
      map("<leader>ghN", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "prev hunk (gitsigns)")

      -- Relabel the rest of the group to the lowercase + (plugin) convention.
      -- ghs / ghr keep their { "n", "x" } modes so they still work on a visual
      -- selection of lines.
      map("<leader>ghs", ":Gitsigns stage_hunk<CR>", "stage hunk (gitsigns)", { "n", "x" })
      map("<leader>ghr", ":Gitsigns reset_hunk<CR>", "reset hunk (gitsigns)", { "n", "x" })
      map("<leader>ghS", gs.stage_buffer, "stage buffer (gitsigns)")
      map("<leader>ghR", gs.reset_buffer, "reset buffer (gitsigns)")
      map("<leader>ghu", gs.undo_stage_hunk, "undo stage hunk (gitsigns)")

      unmap("<leader>ghb")
      unmap("<leader>ghB")
      unmap("<leader>ghD")
    end
  end,
}
