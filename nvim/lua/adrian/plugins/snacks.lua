return {
    "adriangitvitz/snacks.nvim",
    branch = "dev",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },
        dashboard = {
            enabled = true,
            sections = {
                { section = "header" },
                { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
                {
                    icon = " ",
                    title = "Git Status",
                    section = "terminal",
                    enabled = function()
                        return Snacks.git.get_root() ~= nil
                    end,
                    cmd = "git status --short --branch --renames",
                    height = 5,
                    padding = 1,
                    ttl = 5 * 60,
                    indent = 3,
                },
            }
        },
        scroll = {
            enabled = true,
            animate = {
                duration = { step = 15, total = 250 },
                easing = "linear",
            },
            -- faster animation when repeating scroll after delay
            animate_repeat = {
                delay = 100, -- delay in ms before using the repeat animation
                duration = { step = 5, total = 50 },
                easing = "linear",
            },
            -- what buffers to animate
            filter = function(buf)
                return vim.g.snacks_scroll ~= false and vim.b[buf].snacks_scroll ~= false and
                    vim.bo[buf].buftype ~= "terminal"
            end,
        },
        lazygit = {
            enabled = true,
            configure = true,
            theme_path = vim.fs.normalize("~/.config/lazygit/lazygit-theme.yml"),
        },
        notifier = {
            enabled = true,
            timeout = 3000,
        },
        explorer = {
            enabled = true,
            layout = {
                cycle = false
            }
        },
        picker = {
            enabled = true,
            formatters = {
                file = {
                    filename_first = false,
                    filename_only = false,
                    icon_width = 2,
                },
            },
            layout = {
                -- presets options : "default" , "ivy" , "ivy-split" , "telescope" , "vscode", "select" , "sidebar"
                -- override picker layout in keymaps function as a param below
                default = {
                    preview = true,
                    layout = {
                        width = 0.9,
                        height = 0.8,
                        border = "rounded",
                        title = " {title} ",
                        title_pos = "center"
                    }
                },
                cycle = false,
            },
            layouts = {
                select = {
                    preview = false,
                    layout = {
                        backdrop = false,
                        width = 0.6,
                        min_width = 80,
                        height = 0.4,
                        min_height = 10,
                        box = "vertical",
                        border = "rounded",
                        title = "{title}",
                        title_pos = "center",
                        { win = "input",   height = 1,          border = "bottom" },
                        { win = "list",    border = "none" },
                        { win = "preview", title = "{preview}", width = 0.6,      height = 0.4, border = "top" },
                    }
                },
                telescope = {
                    reverse = true, -- set to false for search bar to be on top
                    layout = {
                        box = "horizontal",
                        backdrop = false,
                        width = 0.8,
                        height = 0.9,
                        border = "none",
                        {
                            box = "vertical",
                            { win = "list",  title = " Results ", title_pos = "center", border = "rounded" },
                            { win = "input", height = 1,          border = "rounded",   title = "{title} {live} {flags}", title_pos = "center" },
                        },
                        {
                            win = "preview",
                            title = "{preview:Preview}",
                            width = 0.50,
                            border = "rounded",
                            title_pos = "center",
                        },
                    },
                },
                ivy = {
                    layout = {
                        box = "vertical",
                        backdrop = false,
                        width = 0,
                        height = 0.4,
                        position = "bottom",
                        border = "top",
                        title = " {title} {live} {flags}",
                        title_pos = "left",
                        { win = "input", height = 1, border = "bottom" },
                        {
                            box = "horizontal",
                            { win = "list",    border = "none" },
                            { win = "preview", title = "{preview}", width = 0.5, border = "left" },
                        },
                    },
                },
            }
        },
        terminal = {
            enabled = false,
        },
        quickfile = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        styles = {
            notification = {
                wo = { wrap = true } -- Wrap notifications
            }
        }
    },
    keys = {
        { "<leader><space>", function() require("snacks").picker.smart() end,                                   desc = "Smart Find Files" },
        { "<leader>.",       function() require("snacks").scratch() end,                                        desc = "Toggle Scratch Buffer" },
        { "<leader>S",       function() require("snacks").scratch.select() end,                                 desc = "Select Scratch Buffer" },
        { "<leader>n",       function() require("snacks").notifier.show_history() end,                          desc = "Notification History" },
        { "<leader>lg",      function() require("snacks").lazygit() end,                                        desc = "Lazygit" },
        { "<leader>gl",      function() require("snacks").lazygit.log() end,                                    desc = "Lazygit Logs" },
        { "<leader>es",      function() require("snacks").explorer() end,                                       desc = "Open Snacks Explorer" },
        { "<leader>rN",      function() require("snacks").rename.rename_file() end,                             desc = "Fast Rename Current File" },
        { "<leader>dB",      function() require("snacks").bufdelete() end,                                      desc = "Delete or Close Buffer  (Confirm)" },

        { "<leader>ss",      function() require("snacks").picker.lsp_symbols() end,                             desc = "LSP Symbols" },
        -- Snacks Picker
        { "<leader>pf",      function() require("snacks").picker.files() end,                                   desc = "Find Files (Snacks Picker)" },
        { "<leader>pc",      function() require("snacks").picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
        { "<leader>ps",      function() require("snacks").picker.grep() end,                                    desc = "Grep word" },
        { "<leader>pws",     function() require("snacks").picker.grep_word() end,                               desc = "Search Visual selection or Word",  mode = { "n", "x" } },
        { "<leader>pk",      function() require("snacks").picker.keymaps({ layout = "ivy" }) end,               desc = "Search Keymaps (Snacks Picker)" },

        { "<leader>sm",      function() require("snacks").picker.marks() end,                                   desc = "Marks" },
        { "<leader>sw",      function() require("snacks").picker.grep_word() end,                               desc = "Visual selection or word",         mode = { "n", "x" } },
        { "<leader>sM",      function() require("snacks").picker.man() end,                                     desc = "Man Pages" },
        -- Git Stuff
        { "<leader>gbr",     function() require("snacks").picker.git_branches({ layout = "select" }) end,       desc = "Pick and Switch Git Branches" },

        { "<leader>gL",      function() require("snacks").picker.git_log_line() end,                            desc = "Git Log Line" },

        { "<leader>gf",      function() require("snacks").picker.git_log_file() end,                            desc = "Git Log File" },
        -- Other Utils
        { "<leader>vh",      function() require("snacks").picker.help() end,                                    desc = "Help Pages" },
    },
    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            callback = function()
                -- Setup some globals for debugging (lazy-loaded)
                _G.dd = function(...)
                    Snacks.debug.inspect(...)
                end
                _G.bt = function()
                    Snacks.debug.backtrace()
                end
                vim.print = _G.dd -- Override print to use snacks for `:=` command

                -- Create some toggle mappings
                Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
                Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
                Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
                Snacks.toggle.diagnostics():map("<leader>ud")
                Snacks.toggle.line_number():map("<leader>ul")
                Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
                    :map("<leader>uc")
                Snacks.toggle.treesitter():map("<leader>uT")
                Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map(
                    "<leader>ub")
                Snacks.toggle.inlay_hints():map("<leader>uh")
            end,
        })
    end,
}
