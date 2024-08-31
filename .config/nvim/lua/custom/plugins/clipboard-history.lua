return {
  "AckslD/nvim-neoclip.lua",
  keys = {
    { "<leader>yn", "<cmd>Telescope neoclip<cr>", desc = "yank history" },
  },

  requires = {
    { "nvim-telescope/telescope.nvim" },
  },
  config = function()
    require('neoclip').setup()
  end,

}
