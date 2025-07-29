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
keymap.set('n', '<C-v>', '"+p', vim.tbl_extend('force', opts, { desc = '从系统剪贴板粘贴' }))
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

vim.keymap.set('n', '<leader>t', ':ToggleTerm<CR>', {
  noremap = true,
  silent = true,
  desc = "打开/关闭终端"
})
vim.keymap.set('t', '<C-.>', [[<C-\><C-n>]], { silent = true ,desc="终端模式切换到normal模式"})

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

-- 运行 / 用例 / 下载（全部以 <leader>c 开头）
vim.keymap.set('n', '<leader>r',  '<cmd>CompetiTest run<cr>',              opts) -- 编译+运行全部测试
vim.keymap.set('n', '<leader>c',  '<cmd>CompetiTest run_no_compile<cr>',   opts) -- 仅运行
vim.keymap.set('n', '<leader>a',  '<cmd>CompetiTest add_testcase<cr>',     opts) -- 添加用例
vim.keymap.set('n', '<leader>ea',  '<cmd>CompetiTest edit_testcase<cr>',    opts) -- 编辑用例
vim.keymap.set('n', '<leader>da',  '<cmd>CompetiTest delete_testcase<cr>',  opts) -- 删除用例
vim.keymap.set('n', '<leader>cp',  '<cmd>CompetiTest receive problem<cr>',  opts) -- 下载单题
vim.keymap.set('n', '<leader>co',  '<cmd>CompetiTest receive contest<cr>',  opts) -- 下载整场比赛
vim.keymap.set('n', '<leader>o',  '<cmd>CompetiTest show_ui<cr>',          opts) -- 再次打开结果窗口

vim.keymap.set("n", "<leader>rn", ":IncRename ")

-- 新增键位更符合vscode

-- 上下移动行 / 选区
local function move_line_or_selection(dir)
  local is_visual = vim.fn.mode():match('[vV]')
  if is_visual then
    -- 在可视模式：移动选中块
    local cmd = "'<,'>move " .. (dir == 'up' and "'<-2" or "'>+1")
    vim.cmd('normal! gv')   -- 重新高亮原选区
    vim.cmd(cmd)
    vim.cmd('normal! gv')   -- 移动后再次高亮
  else
    -- 普通模式：移动当前行
    local cmd = dir == 'up' and "move -2" or "move +1"
    vim.cmd(cmd)
  end
end

-- Alt-Up / Alt-Down 上下移动
vim.keymap.set({'n', 'v'}, '<M-Up>',   function() move_line_or_selection('up')   end,
               { noremap = true, silent = true })
vim.keymap.set({'n', 'v'}, '<M-Down>', function() move_line_or_selection('down') end,
               { noremap = true, silent = true })

-- 智能左右方向键：跨行跳转
local function smart_left()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  if col == 0 and row > 1 then
    -- 当前在行首且不是第一行，跳到上一行末尾
    local prev_line_length = vim.fn.col({row - 1, '$'}) - 1
    local target_col = math.max(0, prev_line_length - 1)  -- normal模式下行末是倒数第二个位置
    vim.api.nvim_win_set_cursor(0, {row - 1, target_col})
  else
    -- 正常左移
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Left>', true, false, true), 'n', true)
  end
end

local function smart_right()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line_length = vim.fn.col({row, '$'}) - 1  -- 获取行的实际长度
  local total_lines = vim.api.nvim_buf_line_count(0)
  local mode = vim.fn.mode()

  local at_line_end = false
  if mode == 'i' then
    -- 插入模式：可以在真正的行末（换行符位置）
    at_line_end = (col >= line_length)
  else
    -- normal/visual模式：行末是最后一个字符的位置
    at_line_end = (col >= line_length - 1 and line_length > 0)
  end

  if at_line_end and row < total_lines then
    -- 当前在行末且不是最后一行，跳到下一行开头
    vim.api.nvim_win_set_cursor(0, {row + 1, 0})
  else
    -- 正常右移
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Right>', true, false, true), 'n', true)
  end
end

-- 智能左右方向键映射（适用于所有模式）
vim.keymap.set({'n', 'i', 'v'}, '<Left>', smart_left,
               vim.tbl_extend('force', opts, { desc = '智能左移：行首时跳到上一行末尾' }))
vim.keymap.set({'n', 'i', 'v'}, '<Right>', smart_right,
               vim.tbl_extend('force', opts, { desc = '智能右移：行末时跳到下一行开头' }))

-- Shift+Enter 映射为普通Enter
vim.keymap.set({'n', 'i', 'v'}, '<S-CR>', '<CR>',
               vim.tbl_extend('force', opts, { desc = 'Shift+Enter 等同于 Enter' }))

keymap.set({'n', 'i', 'v'}, '<Esc>',
           function()
           vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
           -- 建议使用 pcall 来安全地调用命令，防止某个命令不存在时报错
           pcall(vim.cmd, 'FormatWrite')
           pcall(vim.cmd, 'write')
           end,
           vim.tbl_extend('force', opts, { desc = '离开插入模式时，先格式化再保存' })
)
