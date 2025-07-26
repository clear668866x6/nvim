local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
    " ██████╗    ██╗         ███████╗    █████╗     ██████╗ ",
    "██╔════╝    ██║         ██╔════╝   ██╔══██╗   ██╔══██╗",
    "██║         ██║         █████╗     ███████║   ██████╔╝",
    "██║         ██║         ██╔══╝     ██╔══██║   ██╔══██╗",
    "██╚════╗    ██║         ██╚════╗   ██║  ██║   ██║  ██╗",
    " ██████╝    ███████╗    ███████╝   ██║  ██║   ██║  ██║",
}
dashboard.section.buttons.val = {
    dashboard.button("f", " " .. " Find file",       "<cmd> lua LazyVim.pick()() <cr>"),
    dashboard.button("n", " " .. " New file",        [[<cmd> ene <BAR> startinsert <cr>]]),
    dashboard.button("r", " " .. " Recent files",    [[<cmd> lua LazyVim.pick("oldfiles")() <cr>]]),
    dashboard.button("g", " " .. " Find text",       [[<cmd> lua LazyVim.pick("live_grep")() <cr>]]),
    dashboard.button("l", "󰒲 " .. " Lazy",            "<cmd> Lazy <cr>"),
    dashboard.button("q", " " .. " Quit",            "<cmd> qa <cr>"),
}

local function footer()
local stats = require("lazy").stats()
local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
return "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
end

dashboard.section.footer.val = footer()
dashboard.config.opts = { noautocmd = true }
alpha.setup(dashboard.opts)
