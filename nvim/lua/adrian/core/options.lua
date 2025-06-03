local opt = vim.opt
vim.g.mapleader = " "

opt.termguicolors = true
opt.splitright = true
opt.splitbelow = true
opt.cursorline = true
opt.backspace = "indent,eol,start"
opt.nu = true
opt.relativenumber = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.wrap = false
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.hlsearch = false
opt.incsearch = true
opt.termguicolors = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.clipboard:append("unnamedplus")
opt.isfname:append("@-@")
opt.updatetime = 50
opt.undodir = os.getenv("HOME") .. "/.config/undodir"
opt.laststatus = 3
opt.fillchars = { eob = " " }
-- opt.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20'
opt.guicursor = 'n-v-c:block'
opt.fileencoding = "utf-8"
opt.laststatus = 2
opt.cmdheight = 2
opt.showmode = true

vim.keymap.set('i', '<C-s>', '<Esc>', { noremap = true, silent = true })
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.shell = "/bin/zsh"

vim.api.nvim_set_keymap('n', 'Q', '<Nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'q', '<Nop>', { noremap = true, silent = true })

local sign = vim.fn.sign_define
vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg = 0, fg = '#993939' })
sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
sign("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
sign('DapStopped', { text = '', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })
