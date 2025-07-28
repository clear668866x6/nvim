local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- 设置高亮组
local function setup_highlight_groups()
    vim.api.nvim_set_hl(0, "AlphaHeader1", { fg = "#ff6b6b", bold = true })
    vim.api.nvim_set_hl(0, "AlphaHeader2", { fg = "#4ecdc4", bold = true })
    vim.api.nvim_set_hl(0, "AlphaHeader3", { fg = "#45b7d1", bold = true })
    vim.api.nvim_set_hl(0, "AlphaHeader4", { fg = "#96ceb4", bold = true })
    vim.api.nvim_set_hl(0, "AlphaHeader5", { fg = "#feca57", bold = true })
    vim.api.nvim_set_hl(0, "AlphaHeader6", { fg = "#ff9ff3", bold = true })
    vim.api.nvim_set_hl(0, "AlphaBorder", { fg = "#6c5ce7", bold = true })
    vim.api.nvim_set_hl(0, "AlphaQuote", { fg = "#a8a8a8", italic = true })
    vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#74b9ff", bold = true })
end

-- 设置高亮组
setup_highlight_groups()

-- 创建大型 NEOVIM 标题，填满更多屏幕空间
dashboard.section.header.val = {
    "",
    "",
    "                   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
    "                   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
    "                   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
    "                   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
    "                   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
    "                   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
    "",
    "",
    "                           🚀 Ready to code with style! 🚀",
    "",
    "",
    "    ████████████████████████████████████████████████████████████████████████████",
    "",
    "",
}

-- 设置标题高亮
dashboard.section.header.opts.hl = "AlphaHeader1"

-- 增强的按钮配置
dashboard.section.buttons.val = {
    dashboard.button("f", "󰈞  Find file",       ":Telescope find_files <CR>"),
    dashboard.button("n", "󰈔  New file",        ":enew <CR>"),
    dashboard.button("r", "󰄉  Recent files",    ":Telescope oldfiles <CR>"),
    dashboard.button("g", "󰊄  Find text",       ":Telescope live_grep <CR>"),
    dashboard.button("p", "󰏖  Projects",        ":Telescope projects <CR>"),
    dashboard.button("l", "󰒲  Lazy",            ":Lazy <CR>"),
    dashboard.button("m", "󱌣  Mason",           ":Mason <CR>"),
    dashboard.button("q", "󰈆  Quit",            ":qa <CR>"),
}

-- 设置按钮样式
dashboard.section.buttons.opts.hl = "AlphaButtons"
dashboard.section.buttons.opts.hl_shortcut = "AlphaHeader2"

-- 配置布局
dashboard.config.layout = {
    dashboard.section.header,
    { type = "padding", val = 2 },
    dashboard.section.buttons,
    { type = "padding", val = 2 },
    dashboard.section.footer,
}

-- 处理 Lazy 窗口冲突
if vim.o.filetype == "lazy" then
    vim.cmd.close()
    vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "AlphaReady",
        callback = function()
            require("lazy").show()
        end,
    })
end

-- 设置 Alpha
alpha.setup(dashboard.config)

-- 动态更新 footer
vim.api.nvim_create_autocmd("User", {
    once = true,
    pattern = "LazyVimStarted",
    callback = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

        dashboard.section.footer.val = {
            "",
            "    ═══════════════════════════════════════════════════════════════════════════",
            "",
            "       " .. os.date("󰃰 %Y年%b%d日") .. "     " .. os.date("🕐 %H:%M:%S"),
            "       ⚡ Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
            "       🎯 " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch .. " • 💻 " .. vim.loop.os_uname().sysname,
            "",
            "    ═══════════════════════════════════════════════════════════════════════════",
            "",
        }

        dashboard.section.footer.opts.hl = "AlphaQuote"
        pcall(vim.cmd.AlphaRedraw)
    end,
})

-- 启动时显示欢迎消息
vim.api.nvim_create_autocmd("User", {
    pattern = "AlphaReady",
    callback = function()
        vim.defer_fn(function()
            if vim.bo.filetype == "alpha" then
                vim.notify("🎉 Welcome back to Neovim!", vim.log.levels.INFO, {
                    title = "Dashboard",
                    timeout = 2000,
                })
            end
        end, 500)
    end,
})
