return {
  --[[
  {
    -- INFO: Highlight markdown codeblocks in neovim.
    "yaocccc/nvim-hl-mdcodeblock.lua",
    after = 'nvim-treesitter',
    config = function()
      require('hl-mdcodeblock').setup()
    end
  },
  --]]
  {
    -- INFO: Making tables in MD easier with :EasyTablesCreateNew
    "Myzel394/easytables.nvim",
  },
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { "markdown" },
}
