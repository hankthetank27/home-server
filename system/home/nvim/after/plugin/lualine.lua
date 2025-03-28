local powerline = require("lualine.themes.powerline")

require("lualine").setup({
	options = {
		theme = powerline,
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
	},
})
