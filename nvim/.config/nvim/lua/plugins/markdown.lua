return {
    {
        "3rd/diagram.nvim",
        dependencies = {
            {
                "3rd/image.nvim",
                opts = {},
                -- 1. Ensure image.nvim starts silent
                config = function(_, opts)
                    require("image").setup(opts)
                    require("image").disable()
                end,
            },
        },
        opts = {
            events = {
                render_buffer = { "InsertLeave", "BufWinEnter", "TextChanged" },
                clear_buffer = { "BufLeave" },
            },
            renderer_options = {
                mermaid = { scale = 1 },
                plantuml = { charset = nil },
                d2 = { scale = nil },
                gnuplot = { size = nil },
            },
        },
    },
    {
        "OXY2DEV/markview.nvim",
        lazy = false,
        opts = {
            preview = {
                enable = false, -- Disable Markview by default
                icon_provider = "devicons",
            },
        },

        config = function(_, opts)
            local preview_enabled = false
            require("markview").setup(opts)

            -- Function to manually clean up diagram windows
            local function close_diagrams()
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local cfg = vim.api.nvim_win_get_config(win)
                    if cfg.relative ~= "" then
                        local buf = vim.api.nvim_win_get_buf(win)
                        if vim.api.nvim_buf_is_valid(buf) then
                            local ok, ft = pcall(vim.api.nvim_get_option_value, buf, "filetype")
                            if ok and (ft == "diagram" or ft == "mermaid" or ft == "plantuml" or ft == "ditaa") then
                                vim.api.nvim_win_close(win, true)
                            end
                        end
                    end
                end
            end

            -- 2. Cleanup once on start (to handle auto-spawned diagrams)
            vim.schedule(function()
                close_diagrams()
            end)

            function TogglePreview()
                preview_enabled = not preview_enabled
                local buf = vim.api.nvim_get_current_buf()

                if preview_enabled then
                    -- A. Enable Everything
                    vim.cmd("Markview enable")

                    if package.loaded["image"] then
                        require("image").enable()
                    end

                    -- B. THE FIX: Force Trigger Events
                    -- This tricks plugins into thinking the buffer was just opened/edited
                    vim.schedule(function()
                        -- 1. Force Image.nvim to render
                        -- Most robust way: trigger BufWinEnter for the current buffer
                        vim.api.nvim_exec_autocmds("BufWinEnter", { buffer = buf })

                        -- 2. Force Diagram.nvim to render
                        -- It listens to TextChanged/InsertLeave, so let's fire one
                        vim.api.nvim_exec_autocmds("TextChanged", { buffer = buf })
                    end)
                else
                    -- C. Disable Everything
                    vim.cmd("Markview disable")

                    if package.loaded["image"] then
                        require("image").disable()
                    end

                    -- D. Manually close windows
                    close_diagrams()
                end

                print("Markdown preview: " .. (preview_enabled and "ON" or "OFF"))
            end
        end,

        keys = {
            {
                "<leader>mp",
                function()
                    TogglePreview()
                end,
                mode = "n",
                desc = "Toggle markdown previews",
            },
        },
    },
}
