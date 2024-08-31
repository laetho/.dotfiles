return {
  'phaazon/hop.nvim',
  branch = 'v2',
  keys = {
    {
      "<leader>j", "<cmd>HopWord<cr>", desc = "Hop Word",
    },
  },
  config = function()
    require 'hop'.setup()
  end,
}
