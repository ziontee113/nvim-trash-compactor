local M = {}

local ns = vim.api.nvim_create_namespace("trash_compactor_ns")
vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

-- stylua: ignore
local labels = {
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ",", ";", "!",
}

local function is_blank(line)
	return not line:match("[%W%P]")
end

local function get_blank_lines_indexes(first_line, lines)
	local blank_indexes = {}
	for i, line in ipairs(lines) do
		if is_blank(line) then
			table.insert(blank_indexes, first_line + i - 1)
		end
	end
	return blank_indexes
end

local function get_them_lines()
	local first_line, last_line = vim.fn.line("w0") - 1, vim.fn.line("w$")
	local lines_in_view = vim.api.nvim_buf_get_lines(0, first_line, last_line, false)

	local blank_line_indexes = get_blank_lines_indexes(first_line, lines_in_view)

	--- clear ns first
	vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

	--- add extmarks
	for i, line in ipairs(blank_line_indexes) do
		vim.api.nvim_buf_set_extmark(0, ns, line, 0, {
			virt_text = { { labels[i], "STS_highlight" } },
			virt_text_pos = "overlay",
		})
	end
end

vim.keymap.set("n", "<a-p>", function()
	get_them_lines()
end, {})

return M
-- {{{nvim-execute-on-save}}}
