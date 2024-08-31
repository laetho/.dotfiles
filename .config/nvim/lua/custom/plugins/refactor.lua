return {
  "ThePrimeagen/refactoring.nvim",
  config = function()
    require("refactoring").setup()
    vim.api.nvim_set_keymap(
      "v",
      "<leader>rr",
      "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
      { desc = "(v)refactor variable", noremap = true }
    )
    -- vim.api.nvim_set_keymap(
    -- "v",
    -- "<leader>rr",
    -- ":lua require('refactoring').select_refactor()<CR>",
    -- { noremap = true, silent = true, expr = false }
    -- )
    -- Remaps for the refactoring operations currently offered by the plugin
    vim.api.nvim_set_keymap(
      "v",
      "<leader>re",
      [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]],
      { desc = "(v)Extract function in same file", noremap = true, silent = true, expr = false }
    )
    vim.api.nvim_set_keymap(
      "v",
      "<leader>rf",
      [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]],
      { desc = "(v)extract function to other file", noremap = true, silent = true, expr = false }
    )
    vim.api.nvim_set_keymap(
      "v",
      "<leader>rv",
      [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]],
      { desc = "(v)extract variable", noremap = true, silent = true, expr = false }
    )
    vim.api.nvim_set_keymap(
      "v",
      "<leader>ri",
      [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
      { desc = "(v)inline variable", noremap = true, silent = true, expr = false }
    )

    -- Extract block doesn't need visual mode
    vim.api.nvim_set_keymap(
      "n",
      "<leader>rb",
      [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]],
      { desc = "(n)extract block", noremap = true, silent = true, expr = false }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<leader>rbf",
      [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]],
      { desc = "(n)extract block to other file", noremap = true, silent = true, expr = false }
    )

    -- Inline variable can also pick up the identifier currently under the cursor without visual mode
    vim.api.nvim_set_keymap(
      "n",
      "<leader>ri",
      [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
      { desc = "(n)inline variable", noremap = true, silent = true, expr = false }
    )
  end,
}
