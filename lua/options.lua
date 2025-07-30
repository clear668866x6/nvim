local opt = vim.opt

vim.scriptencoding = 'utf-8'
opt.encoding = 'utf-8'
opt.fileencoding = 'utf-8'

-- 外观
opt.termguicolors = true     -- 启用真彩色
opt.number = true            -- 显示行号
opt.relativenumber = true      -- 显示相对行号
opt.cursorline = true        -- 高亮当前行
opt.pumheight = 10           -- 补全菜单高度
vim.opt.pumblend = 5

-- 缩进
opt.tabstop = 4              -- Tab 宽度为 4 个空格
opt.shiftwidth = 4           -- 自动缩进宽度
opt.expandtab = true         -- 使用空格替代 Tab
opt.autoindent = true        -- 新行自动缩进

-- 搜索
opt.hlsearch = true          -- 高亮搜索结果
opt.incsearch = true         -- 实时搜索
opt.ignorecase = true        -- 搜索时忽略大小写
opt.smartcase = true         -- 如果搜索词含大写，则不忽略大小写

-- 行为
opt.wrap = false             -- 关闭自动换行
opt.mouse = 'a'              -- 在所有模式下启用鼠标
opt.clipboard = 'unnamedplus' -- 与系统剪贴板共享
opt.splitright = true        -- 水平分割窗口时，新窗口在右侧
opt.splitbelow = true        -- 垂直分割窗口时，新窗口在下方
opt.scrolloff = 8            -- 光标上下保留 8 行的边距

-- 下划线
-- "\e[4:3m" 是用于下划线文本的 ANSI 转义序列，宽度为1像素
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- 启用 'splitright' 选项，以便在右侧分割窗口
vim.opt.splitright = true

-- 行为(不看大小写)
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wildignorecase = true
