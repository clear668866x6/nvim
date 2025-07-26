require('nvim-treesitter.configs').setup({
    -- 需要安装的语言解析器列表
    ensure_installed = { 'c', 'cpp', 'lua', 'python', 'vim', 'markdown', 'json', 'yaml', 'bash' },

    -- 启用语法高亮
    highlight = {
        enable = true,
    },

    -- 启用基于 Treesitter 的缩进
    indent = {
        enable = true,
    },
})
