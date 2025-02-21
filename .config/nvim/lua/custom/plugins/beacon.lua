return {
	{
		'danilamihailov/beacon.nvim',
		lazy = true, -- Lazy loads the plugin
		config = function()
			require('beacon').setup({
				enabled = true,
				speed = 2,
				width = 40,
				winblend = 70,
				fps = 60,
				min_jump = 10,
				cursor_events = { 'CursorMoved' },
				window_events = { 'WinEnter', 'FocusGained' },
				highlight = { bg = 'white', ctermbg = 15 },
			})
		end,
	}
}
