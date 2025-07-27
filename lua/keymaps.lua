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
keymap.set({'n', 'v'}, '<C-a>', 'ggVG', { desc = '全选文件内容' })
keymap.set('n', '<C-z>', 'u', vim.tbl_extend('force', opts, { desc = '撤回' }))
keymap.set('i', '<C-z>', '<C-o>u', vim.tbl_extend('force', opts, { desc = '撤回' }))

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

local map = vim.api.nvim_set_keymap

map('n', '<c-2>', '<Plug>(cokeline-switch-prev)', vim.tbl_extend('force', opts, {
    desc = '将标签页向右移动'
}))

-- 将当前标签页 (buffer) 向左移动
map('n', '<c-1>', '<Plug>(cokeline-switch-next)', vim.tbl_extend('force', opts, {
    desc = '将标签页向左移动'
}))

map("n", "<S-Tab>", "<Plug>(cokeline-focus-prev)", { silent = true })
map("n", "<Tab>", "<Plug>(cokeline-focus-next)", { silent = true })

for i = 1, 9 do
  map(
    "n",
    ("<F%s>"):format(i),
    ("<Plug>(cokeline-focus-%s)"):format(i),
    { silent = true }
  )
  map(
    "n",
    ("<Leader>%s"):format(i),
    ("<Plug>(cokeline-switch-%s)"):format(i),
    { silent = true }
  )
end
-- 将 <leader> 键设置为空格键 (此部分不是 keymap, 保持原样)
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

keymap.set('i', '<Esc>',
           function()
           vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
           -- 建议使用 pcall 来安全地调用命令，防止某个命令不存在时报错
           pcall(vim.cmd, 'FormatWrite')
           pcall(vim.cmd, 'write')
           end,
           vim.tbl_extend('force', opts, { desc = '离开插入模式时，先格式化再保存' })
)
