-- C / C++ file-role icons (mini.icons override).
--
--   .c    -> 󰙱  "C"     (md-language_c)     default color (blue)
--   .cpp  -> 󰙲  "C++"   (md-language_cpp)   default color (blue)
--   .h    -> 󰬏  "h"+box (md-alpha_h_box)    ORANGE
--   .hpp  -> 󰬏  "h"+box (md-alpha_h_box)    ORANGE   <- same as .h (see note)
--   .cppm -> 󰬊  "C"+box (md-alpha_c_box)    default color (blue)
--
-- We override only the GLYPH for sources and the module, leaving mini.icons' own
-- default color untouched (the original azure that .cpp had before any override).
-- ONLY headers get a color override -> orange. That orange is pinned to an
-- explicit hex via our own highlight group, NOT the builtin MiniIconsOrange link
-- (links get reset by `:Lazy reload mini.icons` and can be repainted by the
-- colorscheme); a ColorScheme re-assert keeps it stable. surimiOrange = #ffa066.
--
-- NOTE: there is genuinely NO glyph in any Nerd Font that reads "h++" or "cppm"
-- (verified by parsing the font's `post` glyph-name table). So C and C++ headers
-- share ONE "h" glyph, and the module borrows a "C" glyph. We use the BOXED
-- letters (alpha_h_box / alpha_c_box), not the bare md-alpha_h / md-alpha_c: the
-- bare ones are tiny letters that render far smaller than the cell-filling
-- md-language_cpp badge, while the boxed ones fill the cell and match it in size.

local HDR = "#ffa066" -- orange - header only (.h .hpp ...)

local function set_hl()
    vim.api.nvim_set_hl(0, "IconCxxHeader", { fg = HDR })
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })
set_hl()

-- Glyphs (each verified present via the font's glyph-name table)
local C_SRC = "󰙱" -- md-language_c   -> "C"
local CXX_SRC = "󰙲" -- md-language_cpp -> "C++"
local H_HDR = "󰬏" -- md-alpha_h_box  -> "h" in a box (all headers, C and C++)
local CXX_MOD = "󰬊" -- md-alpha_c_box  -> "C" in a box (stand-in for "cppm")

-- glyph-only: keep mini.icons' default color (blue). hdr: also force orange.
local function g(glyph)
    return { glyph = glyph }
end
local function hdr(glyph)
    return { glyph = glyph, hl = "IconCxxHeader" }
end

return {
    "nvim-mini/mini.icons",
    opts = {
        extension = {
            -- C source ("C") / C header ("h")
            c = g(C_SRC),
            h = hdr(H_HDR),
            -- C++ sources ("C++") -- default color
            cpp = g(CXX_SRC),
            cc = g(CXX_SRC),
            cxx = g(CXX_SRC),
            cp = g(CXX_SRC),
            ["c++"] = g(CXX_SRC),
            -- C++ headers -- same "h" glyph as .h, orange (no "h++" exists)
            hpp = hdr(H_HDR),
            hxx = hdr(H_HDR),
            hh = hdr(H_HDR),
            ["h++"] = hdr(H_HDR),
            tpp = hdr(H_HDR),
            tcc = hdr(H_HDR),
            ipp = hdr(H_HDR),
            icc = hdr(H_HDR),
            inl = hdr(H_HDR),
            -- C++20 module units ("C" in box) -- default color
            cppm = g(CXX_MOD),
            ccm = g(CXX_MOD),
            cxxm = g(CXX_MOD),
            ixx = g(CXX_MOD),
            mpp = g(CXX_MOD),
            mxx = g(CXX_MOD),
        },
    },
}
