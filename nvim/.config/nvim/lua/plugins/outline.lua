return {
    {
        "hedyhli/outline.nvim",
        opts = {

            outline_window = {
                width = 25,
                position = "right",
                relative_width = true,
            },
            outline_items = {
                show_symbol_lineno = true,
            },
            preview_window = {
                -- auto_preview = true,
                -- open_hover_on_preview = true,
            },
            symbols = {
                filter = {
                    -- https://github.com/hedyhli/outline.nvim/blob/6b62f73a6bf317531d15a7ae1b724e85485d8148/lua/outline/symbols.lua
                    "File",
                    "Module",
                    "Namespace",
                    "Package",
                    "Class",
                    "Method",
                    "Property",
                    "Field",
                    "Constructor",
                    "Enum",
                    "Interface",
                    "Function",
                    "Variable",
                    "Constant",
                    "String",
                    "Number",
                    "Boolean",
                    "Array",
                    "Object",
                    "Key",
                    "Null",
                    "EnumMember",
                    "Struct",
                    "Event",
                    "Operator",
                    "TypeParameter",
                    "Component",
                    "Fragment",

                    "TypeAlias",
                    "Parameter",
                    "StaticMethod",
                    "Macro",
                },
            },
        },
    },
}
