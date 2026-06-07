-- Make the ACTIVE buffer tab clearly distinct (kanagawa's dark variants render
-- selected vs unselected tabs almost identically). We pull colors from the live
-- theme (Normal / Function / CursorLine) so it adapts to dragon/wave/lotus.
return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    local function hex(group, key)
      local h = vim.api.nvim_get_hl(0, { name = group, link = false })
      return h[key] and string.format("#%06x", h[key]) or nil
    end

    local fg = hex("Normal", "fg") -- bright text for the active tab
    local accent = hex("Function", "fg") -- themed accent for indicator/modified
    -- Use the Visual (selection) bg for the active tab -- far more visible than
    -- CursorLine, which is too subtle in kanagawa's dark variants.
    local sel_bg = hex("Visual", "bg") or hex("PmenuSel", "bg")
    local dim = hex("Comment", "fg") -- muted side bars for inactive tabs

    opts.options = opts.options or {}
    -- "Boxed" active tab: a true 4-sided box is impossible (the tabline is 1 row
    -- tall, so no top/bottom border). We approximate it -- vertical bars on BOTH
    -- sides (custom separators) + underline (bottom) + a filled background block.
    opts.options.indicator = { style = "underline" }
    opts.options.separator_style = { "│", "│" } -- left/right edges of every tab

    opts.highlights = vim.tbl_deep_extend("force", opts.highlights or {}, {
      buffer_selected = { fg = fg, bg = sel_bg, bold = true, italic = false },
      numbers_selected = { fg = fg, bg = sel_bg, bold = true, italic = false },
      modified_selected = { fg = accent, bg = sel_bg, bold = true },
      indicator_selected = { fg = accent, bg = sel_bg },
      -- the side bars: bright accent around the active tab, dim elsewhere
      separator_selected = { fg = accent, bg = sel_bg },
      separator_visible = { fg = dim },
      separator = { fg = dim },
      diagnostic_selected = { bold = true },
      hint_selected = { bold = true },
      info_selected = { bold = true },
      warning_selected = { bold = true },
      error_selected = { bold = true },
    })
  end,
}
