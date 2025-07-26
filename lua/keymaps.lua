local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- 模式切换
-- 使用 vim.tbl_extend 将通用 opts 和独立的 desc 合并
keymap.set('i', 'jk', '<ESC>', vim.tbl_extend('force', opts, { desc = '使用 jk 退出插入模式' }))

-- 窗口导航
keymap.set('n', '<C-h>', '<C-w>h', vim.tbl_extend('force', opts, { desc = '跳转到左侧窗口' }))
keymap.set('n', '<C-l>', '<C-w>l', vim.tbl_extend('force', opts, { desc = '跳转到右侧窗口' }))
keymap.set('n', '<C-k>', '<C-w>k', vim.tbl_extend('force', opts, { desc = '跳转到上方窗口' }))
keymap.set('n', '<C-j>', '<C-w>j', vim.tbl_extend('force', opts, { desc = '跳转到下方窗口' }))

-- 侧边栏 (NvimTree)
keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', vim.tbl_extend('force', opts, { desc = '切换侧边栏文件树' }))
keymap.set('n', '<leader>tf', ':NvimTreeFindFile<CR>', vim.tbl_extend('force', opts, { desc = '在侧边栏中定位当前文件' }))

-- 标签页与剪贴板
keymap.set('n', '<F5>', ':tabnew<CR>', vim.tbl_extend('force', opts, { desc = '新建标签页' }))
keymap.set('v', '<C-c>', '"+y', vim.tbl_extend('force', opts, { desc = '复制选中内容到系统剪贴板' }))
keymap.set('n', '<C-v>', '"*p', vim.tbl_extend('force', opts, { desc = '从系统剪贴板粘贴' }))

-- Leader 快捷键 (Telescope)
keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', vim.tbl_extend('force', opts, { desc = '使用 Telescope 查找文件' }))

-- 窗口大小调整
keymap.set('n', '<C-Up>', ':resize -2<CR>', vim.tbl_extend('force', opts, { desc = '减小窗口高度' }))
keymap.set('n', '<C-Down>', ':resize +2<CR>', vim.tbl_extend('force', opts, { desc = '增加窗口高度' }))
keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', vim.tbl_extend('force', opts, { desc = '减小窗口宽度' }))
keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', vim.tbl_extend('force', opts, { desc = '增加窗口宽度' }))

-- 缩进
keymap.set('v', '<', '<gv', vim.tbl_extend('force', opts, { desc = '向左缩进' }))
keymap.set('v', '>', '>gv', vim.tbl_extend('force', opts, { desc = '向右缩进' }))

-- 将 C-[ 映射为 Esc 并退出终端
keymap.set('i', '<C-[>', '<Esc>', vim.tbl_extend('force', opts, { desc = '在插入模式下使用 C-[ 替代 Esc' }))
keymap.set('v', '<C-[>', '<Esc>', vim.tbl_extend('force', opts, { desc = '在可视模式下使用 C-[ 替代 Esc' }))
keymap.set('n', '<C-[>', '<Esc>', vim.tbl_extend('force', opts, { desc = '在普通模式下使用 C-[ 替代 Esc' }))

-- 将 <leader> 键设置为空格键 (此部分不是 keymap, 保持原样)
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\" -- 为局部 leader 键设置相同值（可选）

-- 退出插入模式时自动格式化并保存
-- 注意：这个函数映射的 opts 中已经包含了 noremap，但使用 tbl_extend 可以确保 silent 也被应用，使风格统一
keymap.set('i', '<Esc>',
           function()
           vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
           -- 建议使用 pcall 来安全地调用命令，防止某个命令不存在时报错
           pcall(vim.cmd, 'FormatWrite')
           pcall(vim.cmd, 'write')
           end,
           vim.tbl_extend('force', opts, { desc = '离开插入模式时，先格式化再保存' })
)
