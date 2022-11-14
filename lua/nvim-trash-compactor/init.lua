local M = {}

local ns = vim.api.nvim_create_namespace("trash_compactor_ns")
vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

-- stylua: ignore
local labels = {
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "_", "v", "w", "x", "y", "z",
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

local function create_hash_table(lines_indexes)
	local hash_tbl = {}
	for i, line_idx in ipairs(lines_indexes) do
		hash_tbl[labels[i]] = line_idx
	end
	return hash_tbl
end

local function getchar(hash_tbl)
	local ok, keynum = pcall(vim.fn.getchar)
	if ok then
		local key = string.char(keynum)
		if hash_tbl[key] then
			return key
		else
			if string.char(keynum) == "u" then
				return "u"
			end
			return false
		end
	end
end

local function get_them_lines(consecutive)
	vim.api.nvim_buf_clear_namespace(0, ns, 0, -1) -- house cleaning

	local first_line, last_line = vim.fn.line("w0") - 1, vim.fn.line("w$")
	local lines_in_view = vim.api.nvim_buf_get_lines(0, first_line, last_line, false)

	local blank_line_indexes = get_blank_lines_indexes(first_line, lines_in_view)
	local hash_tbl = create_hash_table(blank_line_indexes)

	--- add extmarks
	for i, line in ipairs(blank_line_indexes) do
		vim.api.nvim_buf_set_extmark(0, ns, line, 0, {
			virt_text = { { labels[i], "STS_highlight" } },
			virt_text_pos = "overlay",
		})
	end
	vim.cmd("redraw")

	--- vim.fn.getchar
	local getchar_result = getchar(hash_tbl)
	if getchar_result then
		if getchar_result == "u" then
			vim.cmd("norm! u")
		else
			vim.api.nvim_win_set_cursor(0, { hash_tbl[getchar_result] + 1, 0 })
			vim.cmd("norm! dd")
		end

		if consecutive then
			get_them_lines(true)
		end
	end

	vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

vim.keymap.set("n", "<a-p>", function()
	get_them_lines(true)
end, {})

return M
-- {{{nvim-execute-on-save}}}
