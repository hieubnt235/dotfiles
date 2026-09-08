-- which-key's default sort is { "local", "order", "group", "alphanum", "mod" }.
-- The "group" sorter forces every group (+hunks, +diffview, ...) to the bottom
-- of the list, so <leader>gd sat at the top while <leader>gD sat below all the
-- plain keys. Drop "group" and everything falls into one natural-sorted list,
-- which keeps each lower/UPPER pair adjacent.
return {
  "folke/which-key.nvim",
  opts = {
    sort = { "local", "order", "alphanum", "mod" },
  },
}
