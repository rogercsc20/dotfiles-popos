return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        build = ":TSUpdate",
        config = function()
            local test = 0;
            -- import nvim-treesitter plugin
            local treesitter = require("nvim-treesitter.configs")
            -- configure treesitter
            treesitter.setup({ -- enable syntax highlighting
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                    disable = function(lang, buf)
                        return lang == "scheme" -- Temporary disable until fixed
                    end
                },
                indent = {
                    enable = true,
                },
                autotag = {
                    enable = true,
                },
                -- ensure these language parsers are installed
                ensure_installed = {
                    "json",
                    "javascript",
                    "typescript",
                    "tsx",
                    "yaml",
                    "html",
                    "css",
                    "markdown",
                    "markdown_inline",
                    "bash",
                    "lua",
                    "vim",
                    "dockerfile",
                    "gitignore",
                    "rust",
                    "go",
                    "zig",
                    "gomod",
                    "gosum",
                    "python",
                    "cpp",
                    "c",
                    "comment",
                    "elixir",
                    "latex"
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<C-space>",
                        node_incremental = "<C-space>",
                        scope_incremental = false,
                        node_decremental = "<bs>",
                    },
                },
            })
            vim.treesitter.language.register("markdown", "octo")
        end,
    },
}
