-- [[ LSP Setup ]]
local lspconfig = require("lspconfig")
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

-- Setup mason first
mason.setup()
mason_lspconfig.setup {
  ensure_installed = {
    "terraformls",
    "tflint",
    "gopls",
    "lua_ls",
  },
}

-- Setup neodev before lua_ls
require("neodev").setup()

-- Completion capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- on_attach logic
local on_attach = function(client, bufnr)
  if client.server_capabilities.inlayHintProvider then
    pcall(vim.lsp.inlay_hint.enable, bufnr, true)
  end

  local nmap = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc and "LSP: " .. desc })
  end

  nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
  nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
  nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
  nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  nmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
  nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
  nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
  nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
  nmap("K", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Help")
  nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd")
  nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove")
  nmap("<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "[W]orkspace [L]ist")

  vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
    vim.lsp.buf.format({ async = true })
  end, { desc = "Format current buffer with LSP" })
end


-- Server-specific settings
local server_settings = {
  terraformls = {},
  tflint = {},
  gopls = {
    settings = {
      gopls = {
        codelenses = {
          gc_details = false,
          generate = true,
          regenerate_cgo = true,
          run_govulncheck = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
          vendor = true,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        analyses = {
          unusedparams = true,
          shadow = true,
        },
        staticcheck = true,
        completeUnimported = true,
        gofumpt = true,
        semanticTokens = true,
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        hint = { enable = true },
        diagnostics = { disable = { "missing-fields" } },
      },
    },
  },
}

-- Setup each server manually
for server, config in pairs(server_settings) do
  config.capabilities = capabilities
  config.on_attach = on_attach
  lspconfig[server].setup(config)
end
