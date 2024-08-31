-- [[ Basic Keymaps ]]
vim.keymap.set("n", "<leader>pf", "<cmd> Neotree float toggle <CR>", { desc = "Toggle nvim tree in float mode" })
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- Diagnostic keymaps
vim.keymap.set('n', 'ø', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', 'æ', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
vim.keymap.set('n', '<C-ø>', "<cmd> bprev <CR>", { desc = 'Go to previous buffer' })
vim.keymap.set('n', '<C-æ', "<cmd> bnext <CR>", { desc = 'Go to previous buffer' })
vim.keymap.set('n', 'oo', "<cmd>put<CR>", { desc = 'make newline but stay in normal mode' })
vim.keymap.set('n', 'OO', "<cmd>-put<CR>", { desc = 'make newline above but stay in normal mode' })
vim.keymap.set('n', 'o', "o", { desc = 'make newline undernearth and goto insert mode' })
vim.keymap.set('n', 'O', "O", { desc = 'make newline above and goto insert mode' })
vim.keymap.set('n', '<leader>ih', '<cmd> ToggleInlayHints<CR>', { desc = 'Toggle inlay hints' })
-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- vim: ts=2 sts=2 sw=2 et
