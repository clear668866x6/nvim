
local function on_attach(bufnr)
local api = require("nvim-tree.api")

local function opts(desc)
return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
end

-- ✨ 新增：创建并立即打开文件的函数 ✨
local function create_and_open()
api.fs.create()
-- api.fs.create() 会暂停执行以等待你输入文件名
-- 在你输入完成并按回车后，下面的代码才会执行
api.node.open.edit()
end
-- 定义一个此缓冲区内所有映射通用的 opts 表
local opts = { noremap = true, silent = true, nowait = true }

-- 核心导航和操作
vim.keymap.set("n", "<CR>", api.node.open.edit, vim.tbl_extend('force', opts, { desc = "打开" }))
vim.keymap.set("n", "o", api.node.open.edit, vim.tbl_extend('force', opts, { desc = "打开" }))
vim.keymap.set("n", "s", api.node.open.vertical, vim.tbl_extend('force', opts, { desc = "垂直分割窗口打开" }))

-- 目录和层级导航
vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, vim.tbl_extend('force', opts, { desc = "关闭目录" }))
vim.keymap.set("n", "-", api.tree.change_root_to_parent, vim.tbl_extend('force', opts, { desc = "返回上级目录" }))
vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, vim.tbl_extend('force', opts, { desc = "设为根目录" }))

-- 文件系统操作
-- ✨ 'a' 键映射到新的函数上 ✨
vim.keymap.set("n", "a", create_and_open, vim.tbl_extend('force', opts, { desc = "新建并打开" }))
vim.keymap.set("n", "d", api.fs.remove, vim.tbl_extend('force', opts, { desc = "删除" }))
vim.keymap.set("n", "r", api.fs.rename, vim.tbl_extend('force', opts, { desc = "重命名" }))
vim.keymap.set("n", "c", api.fs.copy.node, vim.tbl_extend('force', opts, { desc = "复制" }))
vim.keymap.set("n", "x", api.fs.cut, vim.tbl_extend('force', opts, { desc = "剪切" }))
vim.keymap.set("n", "p", api.fs.paste, vim.tbl_extend('force', opts, { desc = "粘贴" }))
vim.keymap.set("n", "y", api.fs.copy.filename, vim.tbl_extend('force', opts, { desc = "复制文件名" }))

-- 视图控制
vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, vim.tbl_extend('force', opts, { desc = "切换显示隐藏文件" }))
vim.keymap.set("n", "q", api.tree.close, vim.tbl_extend('force', opts, { desc = "关闭文件树" }))
vim.keymap.set("n", "R", api.tree.reload, vim.tbl_extend('force', opts, { desc = "刷新" }))
vim.keymap.set("n", "g?", api.tree.toggle_help, vim.tbl_extend('force', opts, { desc = "帮助" }))
end

require("nvim-tree").setup({
    sync_root_with_cwd = true,
    update_focused_file = {
        enable = true,
        update_root = true,
    },
    filters = {
        dotfiles = false,
    },
    view = {
        side = "left",
        width = 30,
    },
    on_attach = on_attach,
})
