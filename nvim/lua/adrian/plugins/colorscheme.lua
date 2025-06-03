return {
	"adriangitvitz/zenburn.nvim",
	config = function() 
		require("zenburn").setup()
		vim.cmd("colorscheme zenburn")
	end
}
