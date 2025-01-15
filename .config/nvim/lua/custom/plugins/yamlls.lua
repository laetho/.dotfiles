return {
	{ "b0o/SchemaStore.nvim" },
	{
		"someone-stole-my-name/yaml-companion.nvim",
		dependencies = {
			{ "neovim/nvim-lspconfig" },
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope.nvim" },
		},
		ft = { "yaml" },
		opts = {
			builtin_matchers = {
				-- Detects Kubernetes files based on content
				kubernetes = { enabled = true },
				cloud_init = { enabled = true }
			},

			-- Additional schemas available in Telescope picker
			schemas = {
				{
					name = "wadm oam manifest",
					uri = "https://raw.githubusercontent.com/wasmCloud/wadm/refs/heads/main/oam.schema.json",
				},
			},

			-- Pass any additional options that will be merged in the final LSP config
			lspconfig = {
				flags = {
					debounce_text_changes = 150,
				},
				settings = {
					redhat = { telemetry = { enabled = false } },
					yaml = {
						validate = true,
						format = { enable = true },
						hover = true,
						schemaStore = {
							enable = true,
							url = "https://www.schemastore.org/api/json/catalog.json",
						},
						schemaDownload = { enable = true },
						schemas = {
						},
						trace = { server = "debug" },
					},
				},
			},
		},
		config = function(_, opts)
			local cfg = require("yaml-companion").setup(opts)

			require("telescope").load_extension("yaml_schema")
			require("lspconfig")["yamlls"].setup(cfg)
			vim.api.nvim_create_user_command("YamlSelect", function() vim.cmd("Telescope yaml_schema") end, {})

			-- get schema for current buffer
		end,
	},
}
