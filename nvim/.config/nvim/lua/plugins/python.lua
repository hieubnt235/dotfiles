--https://github.com/LazyVim/LazyVim/discussions/4291
return {
    "mfussenegger/nvim-dap-python",
    config = function()
        require("dap-python").setup("path/to/debugpy")
    end,
}
