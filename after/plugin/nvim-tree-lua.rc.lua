-- 这是你原来的全局键位，不是在这个文件里的
vim.api.nvim_set_keymap("n", "<leader>e", "::NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.opt.termguicolors = true

-- ==========================================================
-- 使用下面这个更新后的 on_attach 函数
-- ==========================================================

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

-- 核心导航和操作
vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
vim.keymap.set("n", "s", api.node.open.vertical, opts("Open: Vertical Split"))

-- 目录和层级导航
vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
vim.keymap.set("n", "-", api.tree.change_root_to_parent, opts("Up"))
vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("CD"))

-- 文件系统操作
-- ✨ 修改：将 'a' 键映射到我们新的函数上 ✨
vim.keymap.set("n", "a", create_and_open, opts("Create and Open"))
vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Name"))

-- 视图控制
vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))
vim.keymap.set("n", "q", api.tree.close, opts("Close"))
vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
end


-- setup 部分保持不变
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
    -- 确保这里调用了上面那个精简后的 on_attach 函数
    on_attach = on_attach,
})
