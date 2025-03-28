return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>fb",
			function()
				require("conform").format({ async = true })
			end,
			mode = "",
			desc = "Format buffer",
		},
	},
	opts = {
		async = true,
		formatters_by_ft = {
			rust = { "rustfmt" },
			lua = { "stylua" },
			nix = { "nixfmt" },
			-- javascript = { "prettierd", "prettier", stop_after_first = true },
		},
		format_on_save = {
			timeout_ms = 1000,
		},
	},
}
