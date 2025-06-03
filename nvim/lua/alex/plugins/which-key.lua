return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end,
    config = function()
        vim.api.nvim_set_hl(0, "WhichKey", { link = "Function" }) -- Example override
        vim.api.nvim_set_hl(0, "WhichKeyGroup", { link = "Keyword" })
        vim.api.nvim_set_hl(0, "WhichKeyDesc", { link = "Identifier" })
        vim.api.nvim_set_hl(0, "WhichKeyBorder", { link = "FloatBorder" })
    end,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },
}
