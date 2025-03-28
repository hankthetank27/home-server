return {
	"stevearc/oil.nvim",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		view_options = {
			show_hidden = true,
		},
		keymaps = {
			["<C-l>"] = false,
			["<C-h>"] = false,
			["<C-s>"] = false,
			["<Leader>vs"] = "actions.select_vsplit",
			["<Leader>hs"] = "actions.select_split",
			["gd"] = {
				desc = "Toggle detail view",
				callback = function()
					local oil = require("oil")
					local config = require("oil.config")
					if #config.columns == 1 then
						oil.set_columns({ "icon", "permissions", "size", "mtime" })
					else
						oil.set_columns({ "icon" })
					end
				end,
			},
		},
	},
}
