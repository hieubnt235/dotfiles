return {
  "lewis6991/gitsigns.nvim",
  -- LazyVim binds <leader>ghp to preview_hunk_INLINE. We prefer:
  --   <leader>ghp = preview_hunk        (floating popup, CLion-style)
  --   <leader>ghi = preview_hunk_inline (inline)
  -- on_attach maps are buffer-local, so we wrap LazyVim's on_attach and add
  -- ours AFTER it (later buffer-local maps override earlier ones).
  opts = function(_, opts)
    local orig = opts.on_attach
    opts.on_attach = function(buffer)
      if orig then
        orig(buffer)
      end
      local gs = require("gitsigns")
      local function map(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = buffer, desc = desc })
      end
      map("<leader>ghp", gs.preview_hunk, "Preview Hunk (popup)")
      map("<leader>ghi", gs.preview_hunk_inline, "Preview Hunk (inline)")
    end
  end,
}
