-- WGSL (WebGPU Shading Language): https://github.com/wgsl-analyzer/wgsl-analyzer
--
-- Nothing custom here -- every piece is stock:
--   * `.wgsl` -> filetype "wgsl" is built into nvim's filetype.lua
--   * nvim-lspconfig ships lsp/wgsl_analyzer.lua (cmd "wgsl-analyzer", root ".git")
--   * mason-registry has the "wgsl-analyzer" package (prebuilt linux binary)
--   * nvim-treesitter has the "wgsl" parser for highlighting
-- The binary is mason-managed only; nothing is taken from system paths.
return {
    {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "wgsl-analyzer" } },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { ensure_installed = { "wgsl" } },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                wgsl_analyzer = {},
            },
        },
    },
}
