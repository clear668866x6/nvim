-- ~/.config/nvim/lua/autocmds.lua
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

local smart_quit_group = vim.api.nvim_create_augroup('SmartQuit', { clear = true })

-- 新增一个标志位，用于防止递归
local is_quitting_all = false

vim.api.nvim_create_autocmd("QuitPre", {
    group = smart_quit_group,
    callback = function()
        if is_quitting_all then
            return
        end

        local wins = vim.api.nvim_list_wins()
        local normal_wins = 0

        -- 统计普通文件窗口数量
        for _, win in ipairs(wins) do
            if vim.api.nvim_win_is_valid(win) then
                local buf = vim.api.nvim_win_get_buf(win)
                if buf and vim.api.nvim_buf_is_valid(buf) and
                   vim.api.nvim_win_get_config(win).relative == "" and
                   vim.bo[buf].buftype == "" then
                    normal_wins = normal_wins + 1
                end
            end
        end

        if normal_wins <= 1 then
            -- 在执行 qall! 之前，立即设置标志位为 true
            is_quitting_all = true

            -- 保存所有已修改的缓冲区
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) and
                   vim.bo[buf].modified and
                   vim.bo[buf].buftype == "" then
                    vim.cmd('silent! write ' .. buf)
                end
            end

            vim.schedule(function()
                vim.cmd('qall!')
            end)
        end
    end,
    desc = "如果只剩最后一个普通窗口，则保存所有并退出 Neovim"
})
