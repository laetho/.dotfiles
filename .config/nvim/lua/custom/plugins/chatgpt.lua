return {
	"jackMort/ChatGPT.nvim",
	event = "VeryLazy",
	config = function()
		local home = vim.fn.expand("$HOME")
		require("chatgpt").setup({
			api_key_cmd = "cat " .. home .. "/chatgptkey.txt",
		})
	end,
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	keys = {
		{
			"<leader>cg",
			"<cmd>ChatGPT<CR>",
			"ChatGPT 3.5 Turbo start",
		},
	}
}
