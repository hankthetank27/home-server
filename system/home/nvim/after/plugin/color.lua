vim.o.termguicolors = true

vim.api.nvim_command([[
    augroup ModifyColors
        autocmd colorscheme * :hi normal guibg=#211f1d 
        hi DiagnosticError guifg=Red
        hi DiagnosticWarn  guifg=DarkOrange
        hi DiagnosticInfo  guifg=Blue
        hi DiagnosticHint  guifg=Green
    augroup END
]])
vim.cmd([[silent! colorscheme melange]])

-- display highlight group under cursor
vim.keymap.set("n", "<Leader>hg", function()
	local result = vim.treesitter.get_captures_at_cursor(0)
	print(vim.inspect(result))
end, { noremap = true, silent = false })

vim.api.nvim_set_hl(0, "Define", { link = "Statement" })
vim.api.nvim_set_hl(0, "Include", { link = "Statement" })
vim.api.nvim_set_hl(0, "PreCondit", { link = "Statement" })
vim.api.nvim_set_hl(0, "PreProc", { link = "Statement" })
vim.api.nvim_set_hl(0, "@function.macro", { link = "Macro" })
vim.api.nvim_set_hl(0, "@constant", { link = "Constant" })
vim.api.nvim_set_hl(0, "@module", { link = "Type" })
vim.api.nvim_set_hl(0, "Macro", { fg = "#cc5f5f" })

-- highlight line number under cursor
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#d1cc87", bold = true })
vim.o.cursorline = true
vim.o.number = true
vim.o.cursorlineopt = "number"
-- alt colorscheme. WIP
--
-- vim.api.nvim_set_hl(0, "String", { fg = "#85b695", italic = true})
-- vim.api.nvim_set_hl(0, "Constant", { fg = "#7f91b2" })
-- vim.api.nvim_set_hl(0, "Function", { fg = "#a3a9ec" })
-- vim.api.nvim_set_hl(0, "Statement", { fg = "#b380b0" })
-- vim.api.nvim_set_hl(0, "Type", { fg = "#e49b5d" })
-- vim.api.nvim_set_hl(0, "Number", { fg = "Statement" })
-- vim.api.nvim_set_hl(0, "Charater", { fg = "Statement" })

-- string = #a3a9ec  cterm=italic gui=italic
-- constant = #7f91b2
-- number = #cf9bc2
-- charater = #7f91b2
-- function = #ebc06d
-- statement = #e49b5d
-- type = #7b9695
-- preproc = #85b695
