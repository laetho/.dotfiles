return {
  "olexsmir/gopher.nvim",
  ft = "go",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function(_, opts)
    require("gopher").setup(opts)
  end,
  build = function()
    vim.cmd([[silent! GoInstallDeps]])
  end,
  keys = {
    {
      "<leader>ce",
      mode = "n",
      "<cmd>GoIfErr<cr>",
      desc = "Generate if err check",
    },
    {
      "<leader>gta",
      mode = "n",
      "<cmd>GoTestAdd<cr>",
      desc = "Generate test for current function",
    }
  },
}
