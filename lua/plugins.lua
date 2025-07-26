local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- 如果没有找到将自动安装 layz.nvim
if not vim.loop.fs_stat(lazypath) then
	print("Installing lazy.nvim....")
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
	print("Done.")
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- 颜色主题
	{
		"EdenEast/nightfox.nvim",
	config=function()
		vim.cmd.colorscheme "dayfox"
	end,
},

-- 让Neovim背景变透明，如果你需要透明的UI或者模糊背景的效果，就需要用上这个插件
{ "xiyaowong/nvim-transparent" },

{
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
},

-- 文件管理器
{
	"nvim-tree/nvim-tree.lua",
	version = "*",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
},
{
	"nvim-lua/plenary.nvim",
},

-- Buffer（文件）Tab 显示插件
{
	"willothy/nvim-cokeline",
	dependencies = {
		"nvim-lua/plenary.nvim",        -- Required for v0.4.0+
		"nvim-tree/nvim-web-devicons", -- If you want devicons
		"stevearc/resession.nvim"       -- Optional, for persistent history
	},
},

-- 代码语法高亮，支持多种语言
{ "nvim-treesitter/nvim-treesitter" },

-- 代码块缩进显示插件
{
	"lukas-reineke/indent-blankline.nvim",
	config = function()
		require("ibl").setup {}
	end,
},

-- 平滑滚动插件
{ "karb94/neoscroll.nvim" },

-- 显示git里增加，删除，编辑地方
{ "lewis6991/gitsigns.nvim",
config = function()
	require("gitsigns").setup()
end,
    },

    -- 一个超快的显示hex颜色的插件
    {
	    "norcalli/nvim-colorizer.lua",
	    config = function()
		    require("colorizer").setup()
	    end,
    },

    -- 在文件顶部显示目前函数名
    { 'nvim-treesitter/nvim-treesitter-context' },

    -- 光标位于一个词语时，页面上其他同一个词语加下划线
    { 'RRethy/vim-illuminate' },

    -- 给成对括号、花括号等添加不同的颜色 会造成一些卡顿
    {
	    "HiPhish/rainbow-delimiters.nvim",
	    dependencies = { "nvim-treesitter/nvim-treesitter" },
    },

	{ "echasnovski/mini.icons", lazy = true, version = false },
    -- LSP 设置
    -- lsp-zero 是一个已经配置好的基础 lsp 功能的合集插件
    {
	    "VonHeikemen/lsp-zero.nvim",
	    branch = "v3.x",
	    lazy = true,
	    config = false,
    },

    -- 以下是 lsp-zero 的依赖插件
    {
	    "neovim/nvim-lspconfig",
	    dependencies = {
		    { 'hrsh7th/cmp-nvim-lsp' },
	    }
    },

    -- 提供 GUI 安装LSP的插件
    {
	    "williamboman/mason.nvim",
	    build = function()
		    vim.cmd("MasonUpdate")
	    end,
	    config = function()
		    require("mason").setup()
	    end,

    },
    { "williamboman/mason-lspconfig.nvim" },

    -- 代码补全
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { 'saadparwaiz1/cmp_luasnip' },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-nvim-lua" },

    -- 提示窗口引擎插件
    {
	    "L3MON4D3/LuaSnip",
	    -- follow latest release.
	    version = "v2.*",
	    dependencies = { "rafamadriz/friendly-snippets" },
	    config = function()
		    require("luasnip.loaders.from_vscode").lazy_load()
	    end,
    },

    -- 补全提示中 VScode 式样的图标
    { "onsails/lspkind-nvim" },


    -- 利用 treesitter 自动补全 html tag
    { "windwp/nvim-ts-autotag",
    config = function()
	    require("nvim-ts-autotag").setup()
    end,
    },

    -- typescript LSP，替代 Mason 里的 tsserver，tsserver 相对比较卡顿，还有错误提示不够清楚
    {
	    "pmizio/typescript-tools.nvim",
	    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	    opts = {},
	    event = "VeryLazy",
    },

    -- 自动补全提示 tailwindcss 颜色
    {
	    "roobert/tailwindcss-colorizer-cmp.nvim",
	    -- optionally, override the default options:
	    config = function()
		    require("tailwindcss-colorizer-cmp").setup({
			    color_square_width = 2,
		    })
	    end,
    },

    -- 提供用于显示诊断等信息的列表
    {
	    "folke/trouble.nvim",
	    dependencies = { "nvim-tree/nvim-web-devicons" },
	    opts = {
	    },
    },

    -- 高亮TODO和FIX等注释
    {
	    "folke/todo-comments.nvim",
	    dependencies = { "nvim-lua/plenary.nvim" },
	    opts = {
	    },
    },
    { "nvim-telescope/telescope.nvim" },
    {
	    'akinsho/toggleterm.nvim',
	    version = "*",
	    opts = { --[[ things you want to change go here]] },
	    config = function()
		    require("toggleterm").setup {
			    -- 热键：ctrl + \ 打开终端
			    open_mapping = [[<c-\>]],
			    -- 终端方向：horizontal (横向)
			    direction = 'horizontal',
			    hide_numbers = true,  -- hide the number column in toggleterm buffers
			    autochdir = false,    -- when neovim changes it current directory the terminal will change it's own when next it's opened
			    persist_mode = true,  -- if set to true (default) the previous terminal mode will be remembered
			    close_on_exit = true, -- close the terminal window when the process exits
			    auto_scroll = true,   -- automatically scroll to the bottom on terminal output
		    }
		    vim.keymap.set('n', '<leader>t', ':ToggleTerm<CR>', {
			    noremap = true,
			    silent = true,
			    desc = "打开/关闭终端"
		    })
	    end,
    },

    -- 通知
    {
	    "rcarriga/nvim-notify",
	    config = function()
		    require("notify").setup({
			    render="compact",
			    stages="slide",
			    top_down = false,
			    background_colour = "#F5F5F5",
		    })
		    -- 可选：设置为默认通知
		    vim.notify = require("notify")
	    end
    },
    -- 格式化
    {
	    "mhartington/formatter.nvim",
	    config = function()
		    -- 自动写入一个临时的 .clang-format，保证 4 空格
		    local function write_temp_cfg()
			    local dir  = vim.fn.stdpath("cache") .. "/formatter"
			    local cfg  = dir .. "/.clang-format"
			    vim.fn.mkdir(dir, "p")
			    if vim.fn.filereadable(cfg) == 0 then
				    vim.fn.writefile({
					    "BasedOnStyle: LLVM",
					    "IndentWidth: 4",
					    "UseTab: Never",
				    }, cfg)
			    end
			    return cfg
		    end

		    require("formatter").setup({
			    filetype = {
				    cpp = {
					    function()
						    local cfg = write_temp_cfg()
						    return {
							    exe  = "clang-format",
							    -- 让 clang-format 只读这个配置文件
							    args = {
								    "--style=file",
								    "--assume-filename=" .. cfg,
							    },
							    stdin = true,
						    }
					    end,
				    },
			    },
		    })
	    end,
    },
    {
	    "hrsh7th/nvim-cmp",
	    dependencies = {
		    "hrsh7th/cmp-nvim-lsp",
		    "hrsh7th/cmp-buffer",
		    "hrsh7th/cmp-path",
		    "hrsh7th/cmp-cmdline",
		    "L3MON4D3/LuaSnip",               -- 1. 片段引擎本身
		    "saadparwaiz1/cmp_luasnip",       -- 2. 连接 nvim-cmp 和 LuaSnip 的“桥梁”
		    "rafamadriz/friendly-snippets", -- 3. (可选但强烈推荐) 预设的片段库
	    },
    },

    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
    { "folke/noice.nvim", dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" }, config = true },
    { "gen740/SmoothCursor.nvim", config = true },
    {
	    "nvim-tree/nvim-web-devicons", opts = {}
    },
    -- 工具
    { "windwp/nvim-autopairs", config = true },
    { "SmiteshP/nvim-navic", config = true },

    {
	    'goolord/alpha-nvim',
	    event = 'VimEnter',
	    dependencies = { 'nvim-tree/nvim-web-devicons' },
    },
    { "folke/zen-mode.nvim", config = true },
    { "petertriho/nvim-scrollbar", config = true },
    { "gorbit99/codewindow.nvim", config = true },
    { "lewis6991/gitsigns.nvim", config = true },
    { "folke/todo-comments.nvim", dependencies = "nvim-lua/plenary.nvim", config = true },
    { "michaelrommel/nvim-silicon", cmd = "Silicon", config = true },
    -- 截图
    {
	    'TobinPalmer/rayso.nvim',
	    cmd = { 'Rayso' },
	    config = function()
		    require('rayso').setup {
			    -- 您可以在这里添加 rayso 的其他配置
		    }

		    -- 可视模式下的快捷键: <leader>pp
		    vim.keymap.set('v', '<leader>pp', '<cmd>Rayso<cr>', {
			    noremap = true,
			    silent = true,
			    desc = "代码截图"
		    })
	    end
    },
	-- 按键映射表
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
		keys = {
			{
				"<leader>?",
				function()
				require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},
	-- 报错提示
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy", -- Or `LspAttach`
		priority = 1000, -- needs to be loaded in first
		config = function()
		require('tiny-inline-diagnostic').setup()
		vim.diagnostic.config({ virtual_text = false }) -- Only if needed in your configuration, if you already have native LSP diagnostics
		end
	},
	{ 'kosayoda/nvim-lightbulb' },

	{
		"j-hui/fidget.nvim",
		opts = {
			-- options
		},
	},
})

vim.notify("🚀 插件配置加载完成！", vim.log.levels.INFO, { title = "Neovim" })
