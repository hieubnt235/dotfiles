-- Make the ACTIVE buffer tab clearly distinct (many themes render selected vs
-- unselected tabs almost identically). We pull colors from the live theme
-- (Normal / Function / Visual / Comment) so it adapts to whatever is loaded.
--
-- `opts.highlights` must stay a FUNCTION here, not a table. Colorschemes hand
-- bufferline a generator rather than a fixed table -- LazyVim sets
-- `opts.highlights = require("catppuccin.special.bufferline").get_theme()`, and
-- get_theme() RETURNS A FUNCTION. bufferline supports that natively
-- (config.lua: `if type(user) == "function" then hl = user(defaults) end`).
-- Deep-extending that function as if it were a table is what threw
-- "expected table, got function". So we wrap: call the previous value when it is
-- callable, then layer our overrides on its result.
--
-- Bonus from wrapping: the hex lookups now run when bufferline resolves its
-- config rather than once at plugin setup. bufferline re-runs that on every
-- ColorScheme event (M.update_highlights), so the tab colors retrack a live
-- `:colorscheme` switch instead of freezing to whatever was active at startup.
return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    local function hex(group, key)
      local h = vim.api.nvim_get_hl(0, { name = group, link = false })
      return h[key] and string.format("#%06x", h[key]) or nil
    end

    opts.options = opts.options or {}
    -- "Boxed" active tab: a true 4-sided box is impossible (the tabline is 1 row
    -- tall, so no top/bottom border). We approximate it -- vertical bars on BOTH
    -- sides (custom separators) + underline (bottom) + a filled background block.
    opts.options.indicator = { style = "underline" }
    opts.options.separator_style = { "│", "│" } -- left/right edges of every tab

    local base = opts.highlights
    opts.highlights = function(defaults)
      local fg = hex("Normal", "fg") -- bright text for the active tab
      local accent = hex("Function", "fg") -- themed accent for indicator/modified
      -- Use the Visual (selection) bg for the active tab -- far more visible than
      -- CursorLine, which is too subtle in most dark themes.
      local sel_bg = hex("Visual", "bg") or hex("PmenuSel", "bg")
      local dim = hex("Comment", "fg") -- muted side bars for inactive tabs

      -- Resolve whatever the colorscheme/LazyVim put here first: a generator
      -- function, a plain table, or nothing at all.
      local inherited = base
      if type(inherited) == "function" then
        inherited = inherited(defaults)
      end

      return vim.tbl_deep_extend("force", inherited or {}, {
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
    end
  end,
}
