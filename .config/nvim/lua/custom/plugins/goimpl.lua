return {
  -- better plugin for using goimpl
  "edolphin-ydf/goimpl.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-lua/popup.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  ft = "go",
  config = function()
    require("telescope").load_extension("goimpl")
  end,
  build = function()
    vim.cmd [[silent! GoInstallDeps]]
  end,
  keys = {
    {
      "<leader>im",
      mode = "n",
      function() require("telescope").extensions.goimpl.goimpl() end,
      desc = "Go impl",
    },
  },
}
