-- ~/.config/nvim/lua/autocmds.lua

-- 创建一个统一的组来管理我们所有的自动命令
local augroup = vim.api.nvim_create_augroup('MyAutoCommands', { clear = true })

-- 保存+格式化
vim.api.nvim_create_autocmd('BufWritePost', {
	group = augroup,
	pattern = { "*.cpp", "*.h", "*.hpp", "*.lua", "*.py" },
	command = 'FormatWrite',
	desc = '在文件保存后自动格式化'
})

vim.api.nvim_create_autocmd('InsertLeave', {
	group = augroup,
	pattern = '*',
	callback = function()
	if vim.bo.buftype == '' and vim.bo.modifiable and vim.bo.modified then
		vim.cmd('silent write')
		end
		end,
		desc = '在离开插入模式时自动保存已修改的文件'
})

-- [[ 最终版本 ]] 智能退出逻辑
local smart_quit_group = vim.api.nvim_create_augroup('SmartQuit', { clear = true })

vim.api.nvim_create_autocmd("QuitPre", {
	group = smart_quit_group,
	callback = function()
	local wins = vim.api.nvim_list_wins()
	local normal_wins = 0

	-- 统计普通文件窗口数量
	for _, win in ipairs(wins) do
		if vim.api.nvim_win_is_valid(win) then
			local buf = vim.api.nvim_win_get_buf(win)
			if buf and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_win_get_config(win).relative == "" and vim.bo[buf].buftype == "" then
				normal_wins = normal_wins + 1
				end
				end
				end

				-- 如果只剩最后一个普通窗口，执行“保存所有并退出”的逻辑
				if normal_wins <= 1 then

					-- 步骤 1: 【核心修正】精确地保存每一个被修改过的“普通文件”
					-- 我们不再使用 'wa'，而是手动遍历
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						-- 检查缓冲区是否：已加载、已修改、并且是普通文件类型
						if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified and vim.bo[buf].buftype == "" then
							-- 用 :silent! write <bufnr> 来安静地、强制地写入单个缓冲区
							-- 这会忽略特殊缓冲区，只写入真正的文件
							vim.cmd('silent! write ' .. buf)
							end
							end

							-- 步骤 2: 保存 CPH 插件的测试用例（这个逻辑是正确的）
							pcall(function()
							-- 确保你在 cph.lua 中已经暴露了这个函数: M.save_cases_to_file = save_cases_to_file
							require('cph').save_cases_to_file()
							end)

							-- 步骤 3: 安排最终的退出命令（这个逻辑也是正确的）
							vim.schedule(function()
							vim.cmd('qall!')
							end)
							end
							end,
							desc = "如果只剩最后一个普通窗口，则保存所有并退出 Neovim"
})
