return {
  'nvim-pack/nvim-spectre',
  vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
    desc = "Toggle Spectre"
  }),
  vim.keymap.set('n', '<leader>SW', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
    desc = "Search current word"
  }),
  vim.keymap.set('v', '<leader>SW', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    desc = "Search current word"
  }),
  vim.keymap.set('n', '<leader>SP', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
    desc = "Search on current file"
  })
}
