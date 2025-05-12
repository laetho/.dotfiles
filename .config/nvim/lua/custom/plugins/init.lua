-- You can add your own plugins here or in other files in this directory!
local function toggle_go_source_and_test()
  local current_file = vim.fn.expand '%:p'

  if current_file:match '_test%.go$' then
    -- If currently in a test file, remove `_test` to go to the source file
    local source_file = current_file:gsub('_test%.go$', '.go')
    vim.cmd('edit ' .. source_file)
  else
    -- If currently in a source file, add `_test` to go to the test file
    local test_file = current_file:gsub('%.go$', '_test.go')
    vim.cmd('edit ' .. test_file)
  end
end

-- This function is triggered when LSP attaches (ensures gopls is attached)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.name == 'gopls' then
      -- Create the command and keybinding when gopls is active
      vim.api.nvim_create_user_command('GoAlternateTestAndSourceFile', toggle_go_source_and_test, {})
      vim.api.nvim_buf_set_keymap(0, 'n', '<leader>ga', ':GoAlternateTestAndSourceFile<CR>', { noremap = true, silent = true })
    end
  end,
})
local function get_schema()
  local schema = require('yaml-companion').get_buf_schema(0)
  if schema.result[1].name == 'none' then
    return ''
  end
  return schema.result[1].name
end

-- require('lualine').setup {
--   sections = {
--     lualine_x = { get_schema },
--   },
-- } -- See the kickstart.nvim README for more information
return {}
