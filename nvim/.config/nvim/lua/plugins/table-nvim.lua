-- Markdown table editing: re-aligns the table as you type; Tab / Shift-Tab jump
-- between cells; Alt+J/K insert a row below/above, Alt+H/L a column left/right,
-- Alt+Shift+HJKL move them, Alt+D deletes a column, Alt+T inserts a new table.
-- Stock keys -- in markdown, Alt+J/K insert rows instead of LazyVim's move-line.
return {
    {
        "SCJangra/table-nvim",
        ft = "markdown",
        opts = {},
    },
}
