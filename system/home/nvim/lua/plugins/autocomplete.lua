return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-path" },
		{ "hrsh7th/cmp-cmdline" },
	},

	config = function()
		local cmp = require("cmp")

		local cmp_mappings = {
			["<C-k>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				else
					fallback()
				end
			end, { "i", "c" }),

			["<C-j>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				else
					fallback()
				end
			end, { "i", "c" }),

			["<C-e>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.abort()
				else
					fallback()
				end
			end, { "i", "c" }),

			["<C-b>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.scroll_docs(-4)
				else
					fallback()
				end
			end, { "i" }),

			["<C-f>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.scroll_docs(4)
				else
					fallback()
				end
			end, { "i" }),

			["<CR>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.confirm({ select = true })
				else
					fallback()
				end
			end, { "i" }),

			["<C-y>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.confirm({ select = true })
				else
					fallback()
				end
			end, { "i", "c" }),

			-- toggle cmp menu in command mode
			-- autocompletes to first option if only one exists
			["<Tab>"] = cmp.mapping(function()
				if cmp.visible() then
					cmp.close()
				else
					cmp.complete()
					if #cmp.get_entries() == 1 then
						cmp.confirm({ select = false })
					end
				end
			end, { "c" }),
		}

		cmp.setup({
			-- completion sources etc in menu
			formatting = {
				fields = { "menu", "abbr", "kind" },
				format = function(entry, item)
					local n = entry.source.name
					local label = ""
					if n == "nvim_lsp" then
						label = "[LSP]"
					elseif n == "nvim_lua" then
						label = "[nvim]"
					else
						label = string.format("[%s]", n)
					end
					item.menu = label
					return item
				end,
			},
			-- select first completion option regardless of LSP preselect item
			preselect = "none",
			completion = {
				completeopt = "menu,menuone,noinsert",
			},
			sources = {
				-- ordering sets priortiy!!
				{ name = "nvim_lsp" },
				{ name = "path" },

				-- optional below...
				{ name = "buffer", keyword_length = 3 },
				-- {name = 'luasnip', keyword_length = 2},
			},
			mapping = cmp_mappings,
			experimental = {
				ghost_text = true,
			},
			snippet = {
				expand = function(args)
					vim.snippet.expand(args.body)
				end,
			},
		})

		cmp.setup.cmdline(":", {
			mapping = cmp_mappings,
			-- only display menu when toggled on
			completion = {
				autocomplete = false,
			},
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
		})

		cmp.setup.cmdline("/", {
			mapping = cmp_mappings,
			sources = cmp.config.sources({
				{ name = "buffer" },
			}),
		})
	end,
}
