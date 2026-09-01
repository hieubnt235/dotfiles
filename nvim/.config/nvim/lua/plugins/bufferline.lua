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
      -- Active-tab background = the EDITOR background. This is the classic tab
      -- metaphor: the selected tab merges with the buffer underneath it, and the
      -- rest of the bar (TabLineFill, always darker/dimmer) falls back.
      -- It is also the only source that can never be a saturated block. Both
      -- obvious alternatives fail on some theme in this config's shelf:
      --   Visual     -> newpaper #0087af (hard cyan)
      --   TabLineSel -> edge     #bf75d6 (purple)
      -- Normal's bg is by definition the calm colour you already read code on.
      local sel_bg = hex("Normal", "bg") or hex("TabLineSel", "bg")
      local dim = hex("Comment", "fg") -- muted side bars for inactive tabs

      -- Resolve whatever the colorscheme/LazyVim put here first: a generator
      -- function, a plain table, or nothing at all.
      local inherited = base
      if type(inherited) == "function" then
        inherited = inherited(defaults)
      end
      -- ...but only KEEP it while catppuccin is the active theme. LazyVim sets
      -- `opts.highlights = require("catppuccin.special.bufferline").get_theme()`
      -- from inside the catppuccin spec, and since catppuccin is loaded eagerly
      -- that injection happens no matter which colorscheme you actually switch to.
      -- The result is catppuccin's palette painted onto kanagawa/newpaper tabs
      -- (e.g. error_selected keeping bg #eff1f6, a light block on a dark bar).
      -- Dropping it lets bufferline derive its own defaults from the live theme.
      if not tostring(vim.g.colors_name or ""):find("catppuccin", 1, true) then
        inherited = nil
      end

      return vim.tbl_deep_extend("force", inherited or {}, {
        buffer_selected = { fg = fg, bg = sel_bg, bold = true, italic = false },
        numbers_selected = { fg = fg, bg = sel_bg, bold = true, italic = false },
        modified_selected = { fg = accent, bg = sel_bg, bold = true, italic = false },
        indicator_selected = { fg = accent, bg = sel_bg },
        -- the side bars: bright accent around the active tab, dim elsewhere
        separator_selected = { fg = accent, bg = sel_bg },
        separator_visible = { fg = dim },
        separator = { fg = dim },
        -- bufferline's OWN defaults set italic = true on the diagnostic groups, so
        -- the active tab's name renders slanted. Italics are disabled everywhere
        -- else for a font-metrics reason (they overflow the cell and get clipped at
        -- `modify_font cell_width 100%`), so turn them off here too.
        diagnostic_selected = { bold = true, italic = false },
        hint_selected = { bold = true, italic = false },
        info_selected = { bold = true, italic = false },
        warning_selected = { bold = true, italic = false },
        error_selected = { bold = true, italic = false },
      })
    end
  end,
}
