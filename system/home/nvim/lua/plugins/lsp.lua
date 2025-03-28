return {
	"neovim/nvim-lspconfig",
	cmd = { "LspInfo", "LspInstall", "LspStart" },
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "hrsh7th/cmp-nvim-lsp" },
	},

	config = function()
		local lsp_defaults = require("lspconfig").util.default_config

		lsp_defaults.capabilities =
			vim.tbl_deep_extend("force", lsp_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())

		vim.diagnostic.config({
			virtual_text = true,
			signs = true,
			-- can be slightly annoying..
			update_in_insert = true,
			severity_sort = true,
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "LSP actions",
			callback = function(event)
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client then
					client.server_capabilities.semanticTokensProvider = nil
				end
				local opts = {
					buffer = event.buf,
					-- remap = false,
				}
				vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
				vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
				vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
				vim.keymap.set("n", "<leader>ee", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
				vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
				vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
				vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
				vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
				vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
				vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
				vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
			end,
		})

		vim.opt.completeopt = { "menu", "menuone", "noselect" }

		local lspconfig = require("lspconfig")

		lspconfig.ts_ls.setup({
			settings = {
				-- completions = {
				--     completeFunctionCalls = true
				-- }
			},
		})

		lspconfig.rust_analyzer.setup({
			settings = {
				["rust-analyzer"] = {
					cargo = {
						allFeatures = true,
					},
					-- completion.autoimport.enable = false,
				},
			},
		})

		lspconfig.lua_ls.setup({
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})

		lspconfig.bashls.setup({
			filetype = { "sh" },
		})

		lspconfig.theme_check.setup({})

		lspconfig.nil_ls.setup({
			settings = {
				nix = {
					flake = {
						-- calls `nix flake archive` to put a flake and its output to store
						autoArchive = true,
					},
				},
			},
		})
	end,
}
