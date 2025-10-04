return {
    "saghen/blink.cmp",
    signature = { enabled = true },

    opts = {
        -- Disable all snippets
        sources = {
            transform_items = function(_, items)
                return vim.tbl_filter(function(item)
                    return item.kind ~= require("blink.cmp.types").CompletionItemKind.Snippet
                end, items)
            end,
        },
    },
}
