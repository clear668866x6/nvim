local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
    "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
    "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
    "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
    "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
    "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
    "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
}
dashboard.section.buttons.val = {
    dashboard.button("f", " " .. " Find file",       " :Telescope find_files <CR>"),
    dashboard.button("n", " " .. " New file",        " :enew <CR>"),
    dashboard.button("r", " " .. " Recent files",    " :Telescope oldfiles <CR>"),
    dashboard.button("g", " " .. " Find text",       " :Telescope live_grep <CR>"),
    dashboard.button("l", "󰒲 " .. " Lazy",            " :Lazy <CR>"),
    dashboard.button("q", " " .. " Quit",            " :qa <CR>"),
}

local function footer()
local stats = require("lazy").stats()
local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
return "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
end

dashboard.section.footer.val = footer()
dashboard.config.opts = { noautocmd = true }
alpha.setup(dashboard.opts)
