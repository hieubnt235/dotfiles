return {
    -- 1. Tell Mason to auto-install xmlformatter
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "xmlformatter",
            },
        },
    },

    -- 2. Tell Conform to use xmlformatter for XML files
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                xml = { "xmlformatter" },
            },

            formatters = {
                xmlformatter = {

                    -- xmlformat [--preserve "pre,literal"] [--blanks] [--compress] [--selfclose] [--indent num] [--indent-char char]
                    --        [--overwrite] [--outfile file] [--encoding enc] [--outencoding enc] [--disable-inlineformatting]
                    --        [--disable-correction] [--preserve-attributes] [--encode-attributes] [--help] < --infile file | file | - >
                    -- prepend_args ensures these flags are injected before the defaults
                    prepend_args = {
                        "--indent",
                        "4",
                        "--blanks",
                        "--preserve-attributes",
                    },
                },
            },
        },
    },
}
