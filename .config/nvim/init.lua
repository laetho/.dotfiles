--[[[]
=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
Kickstart.nvim is *not* a distribution.
Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.termguicolors = true
-- [[ Install `lazy.nvim` plugin manager ]]
require 'lazy-bootstrap'

-- [[ Configure plugins ]]
require 'lazy-plugins'

-- [[ Setting options ]]
require 'options'

-- [[ Basic Keymaps ]]
require 'keymaps'

-- [[ Configure Telescope ]]
-- (fuzzy finder)
require 'telescope-setup'

-- [[ Configure Treesitter ]]
-- (syntax parser for highlighting)
require 'treesitter-setup'

-- [[ Configure LSP ]]
-- (Language Server Protocol)
require 'lsp-setup'

-- [[ Configure nvim-cmp ]]
-- (completion)
require 'cmp-setup'
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

-- TODO: Add custom configuration to their own files and require them instead
-- Recognize .envrc files as shell scripts
vim.cmd([[
  augroup envrc
    autocmd!
    autocmd BufRead,BufNewFile .envrc set filetype=sh
  augroup END
]])
-- Function to toggle inlay hints
function ToggleInlayHints()
  local lsp = vim.lsp
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = lsp.buf_get_clients(bufnr)

  if next(clients) == nil then return end

  for _, client in pairs(clients) do
    if client.server_capabilities.inlayHintProvider then
      local enabled = not client.server_capabilities.inlayHintsEnabled
      client.server_capabilities.inlayHintsEnabled = enabled
      if enabled then
        lsp.inlay_hint.enable(true)
      else
        lsp.inlay_hint.enable(false)
      end
    end
  end
end

function _G.reload_nvim_config()
  for name, _ in pairs(package.loaded) do
    if name:match('^user') or name:match('^plugins') then
      package.loaded[name] = nil
    end
  end
  dofile(vim.env.MYVIMRC)
  print("Configuration reloaded!")
end

function Truncate_lsp_log()
  local lsp_log_path = vim.lsp.get_log_path()
  local max_size = 1024 * 1024 -- 1 MB limit
  local file = io.open(lsp_log_path, "r+")
  if file then
    local size = file:seek("end")
    if size > max_size then
      -- Truncate to the last few KB (e.g., 10 KB)
      file:seek("end", -10240)
      local content = file:read("*a")
      file:close()

      -- Rewrite with truncated content
      file = io.open(lsp_log_path, "w")
      file:write(content)
      file:close()
      print("LSP log truncated to 10 KB")
    end
  end
end

vim.cmd [[
  augroup LspLogTruncate
    autocmd!
    autocmd VimEnter * lua Truncate_lsp_log()
  augroup END
]]

vim.api.nvim_set_keymap('n', '<leader>rr', ':lua reload_nvim_config()<CR>', { noremap = true, silent = true })
-- Command to toggle inlay hints
vim.api.nvim_create_user_command('ToggleInlayHints', ToggleInlayHints, {})
