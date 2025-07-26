local status, telescope = pcall(require, "telescope")
if not status then
  return
end
local builtin = require("telescope.builtin")

-- Telescope 设置的主要是键位
-- 空格+s 打开智能打开界面，可以当作是历史记录
vim.api.nvim_set_keymap(
  "n",
  "<Space>s",
  "<Cmd>lua require('telescope').extensions.smart_open.smart_open()<CR>",
  { noremap = true, silent = true }
)

-- 当前文件夹下查找文件名
vim.keymap.set("n", "<Space>t", function()
  builtin.find_files({
    respect_gitignore = false,
    no_ignore = true,
    hidden = true,
    file_ignore_patterns = {
      "node_modules",
      ".git",
      ".next",
      ".lock",
      "package-lock.json",
      ".jpg",
      "jpeg",
      "png",
      "PNG",
      "JPEG",
      "JPG",
    },
  })
end)

-- 当前文件夹下查找内容
vim.keymap.set("n", "<Space>g", function()
  builtin.live_grep({
    respect_gitignore = false,
    no_ignore = true,
    hidden = false,
    file_ignore_patterns = {
      "node_modules",
      ".git",
      ".next",
      ".lock",
      "package-lock.json",
      ".jpg",
      "jpeg",
      "png",
      "PNG",
      "JPEG",
      "JPG",
    },
  })
end)

-- 显示当前打开的文件（buffer)
vim.keymap.set("n", "<Space>b", function()
  builtin.buffers()
end)

-- 显示所有插件的 help 文档索引
vim.keymap.set("n", "<Space>h", function()
  builtin.help_tags()
end)

-- 显示上一次查找结果
vim.keymap.set("n", "<Space>r", function()
  builtin.resume()
end)

-- 显示当前文件夹/项目所有语法错误
vim.keymap.set("n", "<Space>e", function()
  builtin.diagnostics()
end)

-- 显示当前文件夹/项目所有TODO/NOTE等注释，配合 folke/todo-comments.nvim
vim.keymap.set("n", "<Space>d", ":TodoTelescope<Return>", { silent = true })

-- telescope 有个奇怪的特性，就是打开文件缺省进入 insert 模式，非常不方便，这段是修改成打开文件是 normal 模式
-- https://github.com/nvim-telescope/telescope.nvim/issues/2027#issuecomment-1561836585
vim.api.nvim_create_autocmd("WinLeave", {
  callback = function()
    if vim.bo.ft == "TelescopePrompt" and vim.fn.mode() == "i" then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "i", false)
    end
  end,
})
