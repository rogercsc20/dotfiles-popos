return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local builtin = require("telescope.builtin")
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        telescope.setup({
            defaults = {
                pickers = {
                    find_files = {
                        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
                    },
                },
                vimgrep_arguments = {
                    "rg",
                    "-L",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--no-ignore-vcs"
                },
                -- file_ignore_patterns = { "venv", "%.venv" },
                file_ignore_patterns = { "node_modules", "%.pyc" },
                layout_strategy = "vertical",
                layout_config = {
                    vertical = {
                        prompt_position = "bottom",
                        preview_width = 0.5,
                    },
                },
                path_display = { "truncate " },
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous, -- move to prev result
                        ["<C-j>"] = actions.move_selection_next,     -- move to next result
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                    },
                },
            },
        })

        telescope.load_extension("fzf")
        function SearchInFilesWithExtension(extension)
            require("telescope.builtin").find_files({
                prompt_title = "Buscar en archivos con extensión " .. extension,
                find_command = { "rg", "--files", "--iglob", "*." .. extension },
            })
        end

        vim.api.nvim_create_user_command("TelescopeFindFilesWithExt", function(opts)
            SearchInFilesWithExtension(opts.args)
        end, { nargs = 1 })

        function GrepInFilesWithExtension(extension)
            builtin.live_grep({
                prompt_title = "Buscar en archivos con extensión " .. extension,
                additional_args = function()
                    return { "--glob", "*." .. extension }
                end,
            })
        end

        vim.api.nvim_create_user_command("TelescopeGrepWithExt", function(opts)
            GrepInFilesWithExtension(opts.args)
        end, { nargs = 1 })
        -- set keymaps
        local keymap = vim.keymap -- for conciseness

        keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
        keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
        keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Fuzzy find recent buffers" })
        keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
        keymap.set("n", "<leader>fj", "<cmd>Telescope jumplist<cr>", { desc = "Find string in cwd" })
        keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "Find string in cwd" })
        keymap.set("n", "<leader>fm", "<cmd>Telescope marks<cr>", { desc = "Find string in cwd" })
        keymap.set("n", "<leader>fg", "<cmd>Telescope git_status<cr>", { desc = "Find string in cwd" })
        keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
        vim.keymap.set("n", "<leader>fD", function()
            local search_dir = vim.fn.input("Search Directory: ", "", "file")
            local command = string.format([[Telescope live_grep search_dirs={'%s'}]], search_dir)
            vim.cmd(command)
        end, { desc = "Live grep in specified directory" })
        keymap.set("n", "<C-g>", builtin.git_files, { desc = "Show git files" })
        keymap.set("n", "<leader>tf", ":Telescope current_buffer_fuzzy_find<CR>", { desc = "Buffer fuzzy find" })
    end,
}
