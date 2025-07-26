local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- 模式切换
keymap.set('i', 'jk', '<ESC>', { desc = '使用 jk 退出插入模式' })

-- 窗口导航
keymap.set('n', '<C-h>', '<C-w>h', { desc = '跳转到左侧窗口' })
keymap.set('n', '<C-l>', '<C-w>l', { desc = '跳转到右侧窗口' })
keymap.set('n', '<C-k>', '<C-w>k', { desc = '跳转到上方窗口' })
keymap.set('n', '<C-j>', '<C-w>j', { desc = '跳转到下方窗口' })

local map = vim.api.nvim_set_keymap

map('n', '<leader>t', ':NvimTreeToggle', opts)
map('n', '<leader>tf', '<Esc>:NvimTreeFindFile<CR>', opts)
map('n', '<F5>', '<Esc>:tabnew<CR>', opts)
map('v', '<C-c>', '"+y', opts)
map('n', '<C-v>', '"*p', opts)

-- Leader 快捷键 (将在插件配置中大量使用)
keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = '查找文件' })

vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', opts)

vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)
-- 让 Esc 退出终端模式
vim.api.nvim_set_keymap('t', '<C-[>', '<C-\\><C-n>', { noremap = true, silent = true })
-- 将 C-[ 映射为 Esc
vim.keymap.set('i', '<C-[>', '<Esc>', { noremap = true, silent = true })
vim.keymap.set('v', '<C-[>', '<Esc>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-[>', '<Esc>', { noremap = true, silent = true })
-- 将 <leader> 键设置为空格键
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"-- 为局部 leader 键设置相同值（可选）

keymap.set('i', '<Esc>',
           function()
           vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
           vim.cmd('FormatWrite')
           vim.cmd('write')
           end,
           { noremap = true, desc = '离开插入模式时，先格式化再保存' }
)
