return {
	-- treesitter
	-- local dev
	-- dir = '~/programming_projects/nvim-treesitter',
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {},
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true,
			},
		})

		require("vim.treesitter.query").add_directive("set-lang-by-filetype!", function(_, _, bufnr, pred, metadata)
			local function find_nth_dot_from_end(str, n)
				for i = #str, 1, -1 do
					if str:sub(i, i) == "." then
						n = n - 1
						if n <= 0 then
							return i
						end
					end
				end
				return nil
			end
			local filename = vim.fn.expand("#" .. bufnr .. ":t")
			local dots_in_extension = select(2, string.gsub(pred[2], "%.", "")) + 1
			local extension_index = find_nth_dot_from_end(filename, dots_in_extension)
			if not extension_index then
				return
			end
			if pred[2] == filename:sub(extension_index + 1) then
				metadata["injection.language"] = pred[3]
			end
		end, {})

		local liquid_injections = [[
      ((template_content) @injection.content
        (#set-lang-by-filetype! "liquid" "html")
        (#set-lang-by-filetype! "js.liquid" "javascript")
        (#set-lang-by-filetype! "css.liquid" "css")
        (#set-lang-by-filetype! "scss.liquid" "scss")
        (#set! injection.combined))

      (javascript_statement
        (js_content) @injection.content
        (#set! injection.language "javascript")
        (#set! injection.combined))

      (schema_statement
        (json_content) @injection.content
        (#set! injection.language "json")
        (#set! injection.combined))

      (style_statement
        (style_content) @injection.content
        (#set! injection.language "css")
        (#set! injection.combined))

      ((comment) @injection.content
        (#set! injection.language "comment"))
    ]]

		vim.treesitter.query.set("liquid", "injections", liquid_injections)
	end,
}
-- ((front_matter) @injection.content
--     (#set! injection.language "yaml")
--     (#offset! @injection.content 1 0 -1 0)
--     (#set! injection.include-children))
