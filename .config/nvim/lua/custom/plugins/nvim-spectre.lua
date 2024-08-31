return {
	"windwp/nvim-spectre",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require('spectre').setup()
	end,
	-- Lazy loading triggers:
	-- You can specify events, commands, or filetype(s) to trigger the load.
	-- Here are a few examples; tailor them to your needs:

	-- To load on an event:
	event = "BufRead", -- Adjust the event to your preference

	-- To load on calling a command:
	cmd = "Spectre", -- Loads when the Spectre command is called
}
