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
	"rose-pine/neovim",
	config=function()
		vim.cmd.colorscheme "rose-pine-dawn"
	end,
},

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

    -- Git blame 和历史查看 (类似 GitLens)
    {
	    "f-person/git-blame.nvim",
	    config = function()
		    require("gitblame").setup({
			    enabled = true,
			    message_template = " <summary> • <date> • <author>",
			    date_format = "%m-%d-%Y %H:%M:%S",
			    virtual_text_column = 1,
		    })
		    vim.keymap.set("n", "<leader>gb", ":GitBlameToggle<CR>", { desc = "切换 Git Blame" })
	    end,
    },

    -- Git 历史和差异查看器
    {
	    "sindrets/diffview.nvim",
	    dependencies = "nvim-lua/plenary.nvim",
	    config = function()
		    require("diffview").setup({
			    enhanced_diff_hl = true,
			    view = {
				    default = { layout = "diff2_horizontal" },
				    merge_tool = { layout = "diff3_horizontal" },
			    },
		    })
		    vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "打开 Git 差异视图" })
		    vim.keymap.set("n", "<leader>gh", ":DiffviewFileHistory<CR>", { desc = "查看文件历史" })
		    vim.keymap.set("n", "<leader>gc", ":DiffviewClose<CR>", { desc = "关闭差异视图" })
	    end,
    },

    -- Git 文件历史浏览器
    {
	    "tpope/vim-fugitive",
	    config = function()
		    vim.keymap.set("n", "<leader>gs", ":Git<CR>", { desc = "Git 状态" })
		    vim.keymap.set("n", "<leader>gl", ":Git log --oneline<CR>", { desc = "Git 日志" })
	    end,
    },

    -- 一个超快的显示hex颜色的插件
    {
		"brenoprata10/nvim-highlight-colors",
		config = function()
		require("nvim-highlight-colors").setup({
			render = 'background',
			enable_named_colors = true,
			enable_tailwind = true,
		})
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

    -- C++ 增强插件
    {
	    "p00f/clangd_extensions.nvim",
	    ft = { "c", "cpp" },
	    config = function()
		    require("clangd_extensions").setup({
			    server = {
				    cmd = {
					    "clangd",
					    "--background-index",
					    "--clang-tidy",
					    "--header-insertion=iwyu",
					    "--completion-style=detailed",
					    "--function-arg-placeholders",
					    "--fallback-style=llvm",
				    },
				    init_options = {
					    usePlaceholders = true,
					    completeUnimported = true,
					    clangdFileStatus = true,
				    },
			    },
			    extensions = {
				    autoSetHints = true,
				    inlay_hints = {
					    inline = false,
					    only_current_line = false,
					    only_current_line_autocmd = "CursorHold",
					    show_parameter_hints = true,
					    parameter_hints_prefix = "<- ",
					    other_hints_prefix = "=> ",
					    max_len_align = false,
					    max_len_align_padding = 1,
					    right_align = false,
					    right_align_padding = 7,
					    highlight = "Comment",
				    },
			    },
		    })
	    end,
    },

    -- Rust 增强插件
    {
	    "mrcjkb/rustaceanvim",
	    version = "^5",
	    lazy = false,
	    ft = { "rust" },
	    config = function()
		    vim.g.rustaceanvim = {
			    server = {
				    on_attach = function(client, bufnr)
					    vim.keymap.set("n", "<leader>ca", function()
						    vim.cmd.RustLsp('codeAction')
					    end, { desc = "代码操作", buffer = bufnr })
					    vim.keymap.set("n", "<leader>dr", function()
						    vim.cmd.RustLsp('debuggables')
					    end, { desc = "Rust 调试", buffer = bufnr })
				    end,
				    default_settings = {
					    ['rust-analyzer'] = {
						    cargo = {
							    allFeatures = true,
							    loadOutDirsFromCheck = true,
							    runBuildScripts = true,
						    },
						    checkOnSave = {
							    allFeatures = true,
							    command = "clippy",
							    extraArgs = { "--no-deps" },
						    },
						    procMacro = {
							    enable = true,
							    ignored = {
								    ["async-trait"] = { "async_trait" },
								    ["napi-derive"] = { "napi" },
								    ["async-recursion"] = { "async_recursion" },
							    },
						    },
					    },
				    },
			    },
		    }
	    end,
    },

    -- Python 增强插件
    'linux-cultist/venv-selector.nvim',
		dependencies = { 'neovim/nvim-lspconfig', 'nvim-telescope/telescope.nvim', 'mfussenegger/nvim-dap-python' },
		opts = {
			-- Your options go here
			-- name = "venv",
			-- auto_refresh = false
		},
		event = 'VeryLazy', -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
		keys = {
			-- Keymap to open VenvSelector to pick a venv.
			{ '<leader>vs', '<cmd>VenvSelect<cr>' },
			-- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
			{ '<leader>vc', '<cmd>VenvSelectCached<cr>' },
	},

    -- Python 调试支持
    {
	    "mfussenegger/nvim-dap-python",
	    ft = "python",
	    dependencies = {
		    "mfussenegger/nvim-dap",
		    "rcarriga/nvim-dap-ui",
	    },
	    config = function()
		    local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
		    require("dap-python").setup(path)
		    vim.keymap.set("n", "<leader>dpr", function() require('dap-python').test_method() end, { desc = "调试 Python 方法" })
	    end,
    },

    -- 通用调试适配器
    {
	    "mfussenegger/nvim-dap",
	    dependencies = {
		    "rcarriga/nvim-dap-ui",
		    { "nvim-neotest/nvim-nio" },
		    "theHamsta/nvim-dap-virtual-text",
	    },
	    config = function()
		    local dap = require("dap")
		    local dapui = require("dapui")

		    dapui.setup()
		    require("nvim-dap-virtual-text").setup()

		    -- 调试快捷键
		    vim.keymap.set("n", "<F5>", function() dap.continue() end, { desc = "开始/继续调试" })
		    vim.keymap.set("n", "<F10>", function() dap.step_over() end, { desc = "单步跳过" })
		    vim.keymap.set("n", "<F11>", function() dap.step_into() end, { desc = "单步进入" })
		    vim.keymap.set("n", "<F12>", function() dap.step_out() end, { desc = "单步退出" })
		    vim.keymap.set("n", "<leader>b", function() dap.toggle_breakpoint() end, { desc = "切换断点" })
		    vim.keymap.set("n", "<leader>B", function() dap.set_breakpoint(vim.fn.input('断点条件: ')) end, { desc = "条件断点" })
		    vim.keymap.set("n", "<leader>dr", function() dap.repl.open() end, { desc = "打开调试 REPL" })
		    vim.keymap.set("n", "<leader>dl", function() dap.run_last() end, { desc = "运行上次调试" })

		    -- 自动打开/关闭 DAP UI
		    dap.listeners.after.event_initialized["dapui_config"] = function()
			    dapui.open()
		    end
		    dap.listeners.before.event_terminated["dapui_config"] = function()
			    dapui.close()
		    end
		    dap.listeners.before.event_exited["dapui_config"] = function()
			    dapui.close()
		    end
	    end,
    },

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
    {
	    "hrsh7th/nvim-cmp",
	    dependencies = {
		    "hrsh7th/cmp-nvim-lsp",
		    "hrsh7th/cmp-buffer",
		    "hrsh7th/cmp-path",
		    "hrsh7th/cmp-cmdline",
		    "L3MON4D3/LuaSnip",               -- 1. 片段引擎本身
		    "saadparwaiz1/cmp_luasnip",       -- 2. 连接 nvim-cmp 和 LuaSnip 的"桥梁"
		    "rafamadriz/friendly-snippets", -- 3. (可选但强烈推荐) 预设的片段库
	    },
    },

    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
    { "folke/noice.nvim", dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" }, config = true },
	{
		"sphamba/smear-cursor.nvim",
		opts = {
			smear_between_buffers = true,
			smear_between_neighbor_lines = true,
			scroll_buffer_space = true,
			legacy_computing_symbols_support = true,
			smear_insert_mode = true,
		},
	},
    {
	    "nvim-tree/nvim-web-devicons", opts = {}
    },
	{ "CRAG666/code_runner.nvim", config = true },
	{
		'vyfor/cord.nvim',
		build = ':Cord update',
		-- opts = {}
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
	{
		"gorbit99/codewindow.nvim",
		config = function()
		require('codewindow').setup({
			-- 添加配置以避免弃用警告
			exclude_filetypes = { 'help', 'startify', 'dashboard' },
		})
		end
	},
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
	{ 'kosayoda/nvim-lightbulb' },

	{
		'kosayoda/nvim-lightbulb',
		config = function()
		require('nvim-lightbulb').setup({
			priority = 10,
			hide_in_unfocused_buffer = true,
			link_highlights = true,
			validate_config = 'auto', -- 新的验证配置选项
			action_kinds = nil,
			sign = {
				enabled = true,
				text = "💡",
				hl = "LightBulbSign",
			},
			virtual_text = {
				enabled = false,
				text = "💡",
				pos = "eol",
				hl = "LightBulbVirtualText",
				hl_mode = "combine",
			},
			float = {
				enabled = false,
				text = "💡",
				hl = "LightBulbFloatWin",
				win_opts = {},
			},
			status_text = {
				enabled = false,
				text = "💡",
				text_unavailable = ""
			},
			autocmd = {
				enabled = true,
				updatetime = 200,
				events = { "CursorHold", "CursorHoldI" },
				pattern = { "*" },
			},
			ignore = {
				clients = {},
				ft = {},
				actions_without_kind = false,
			},
		})
		end
	},
	-- 面包屑
	{
		'Bekaboo/dropbar.nvim',
		-- optional, but required for fuzzy finder support
		dependencies = {
			'nvim-telescope/telescope-fzf-native.nvim',
			build = 'make'
		},
		config = function()
		local dropbar_api = require('dropbar.api')
		vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
		vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
		vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
		end
	},
	{
		'2kabhishek/nerdy.nvim',
		dependencies = {
			'folke/snacks.nvim',
		},
		cmd = 'Nerdy',
		opts = {
			max_recents = 30, -- Configure recent icons limit
			add_default_keybindings = true, -- Add default keybindings
			use_new_command = true, -- Enable new command system
		}
	},
	{
		"sontungexpt/bim.nvim",
		event = "InsertEnter",
		config = function()
		require("bim").setup()
		end
	},
	{
		'numToStr/Comment.nvim',
		opts = {
			-- add any options here
		}
	},
	{
		'mcauley-penney/visual-whitespace.nvim',
		config = true,
		event = "ModeChanged *:[vV\22]", -- optionally, lazy load on entering visual mode
		opts = {},
	},
	{
		'vidocqh/auto-indent.nvim',
		opts = {},
	},
	{
		"soulis-1256/eagle.nvim",
		opts = {
			--override the default values found in config.lua
		}
	},
	{
		'dnlhc/glance.nvim',
		cmd = 'Glance'
	},
	{
		'rachartier/tiny-inline-diagnostic.nvim',
		event = 'LspAttach',
		config = function()
		require('tiny-inline-diagnostic').setup({
			show_diagnostic_text = true,
		})
		end
	},
	{ 'kosayoda/nvim-lightbulb' ,
		config=function()
		require("nvim-lightbulb").setup({
			autocmd = { enabled = true }
		})
		end
	},
	{
		'mawkler/modicator.nvim',
		dependencies = 'mawkler/onedark.nvim', -- Add your colorscheme plugin here
		init = function()
		-- These are required for Modicator to work
		vim.o.cursorline = true
		vim.o.number = true
		vim.o.termguicolors = true
		end,
		opts = {
			-- Warn if any required option above is missing. May emit false positives
			-- if some other plugin modifies them, which in that case you can just
			-- ignore. Feel free to remove this line after you've gotten Modicator to
			-- work properly.
			show_warnings = true,
		}
	},
	{
		{'akinsho/toggleterm.nvim', version = "*", config = true}
	},
	{
		'xeluxee/competitest.nvim',
		dependencies = 'MunifTanjim/nui.nvim',
	},
	{
		"tris203/precognition.nvim",
		--event = "VeryLazy",
		opts = {
			-- startVisible = true,
			-- showBlankVirtLine = true,
			-- highlightColor = { link = "Comment" },
			-- hints = {
			--      Caret = { text = "^", prio = 2 },
			--      Dollar = { text = "$", prio = 1 },
			--      MatchingPair = { text = "%", prio = 5 },
			--      Zero = { text = "0", prio = 1 },
			--      w = { text = "w", prio = 10 },
			--      b = { text = "b", prio = 9 },
			--      e = { text = "e", prio = 8 },
			--      W = { text = "W", prio = 7 },
			--      B = { text = "B", prio = 6 },
			--      E = { text = "E", prio = 5 },
			-- },
			-- gutterHints = {
			--     G = { text = "G", prio = 10 },
			--     gg = { text = "gg", prio = 9 },
			--     PrevParagraph = { text = "{", prio = 8 },
			--     NextParagraph = { text = "}", prio = 8 },
			-- },
			-- disabled_fts = {
			--     "startify",
			-- },
		},
	},

	{
		"smjonas/inc-rename.nvim",
		opts = {}
	},
	{
		'stevearc/dressing.nvim',
		config = function()
		require('dressing').setup();
		end
	},
	{
		"m4xshen/smartcolumn.nvim",
		opts = {}
	},

	-- 测试运行器
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			-- 语言特定适配器
			"nvim-neotest/neotest-python",
			"rouge8/neotest-rust",
			"alfaix/neotest-gtest", -- C++ Google Test
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-python")({
						dap = { justMyCode = false },
						args = {"--log-level", "DEBUG"},
						runner = "pytest",
					}),
					require("neotest-rust") {
						args = { "--no-capture" },
						dap_adapter = "lldb",
					},
					require("neotest-gtest").setup({}),
				},
			})

			-- 测试快捷键
			vim.keymap.set("n", "<leader>tt", function() require("neotest").run.run() end, { desc = "运行最近的测试" })
			vim.keymap.set("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "运行文件中的所有测试" })
			vim.keymap.set("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "切换测试摘要" })
			vim.keymap.set("n", "<leader>to", function() require("neotest").output.open({ enter = true }) end, { desc = "打开测试输出" })
		end,
	},

	-- 代码覆盖率显示
	{
		"andythigpen/nvim-coverage",
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
			require("coverage").setup({
				commands = true,
				highlights = {
					covered = { fg = "#C3E88D" },
					uncovered = { fg = "#F07178" },
				},
				signs = {
					covered = { hl = "CoverageCovered", text = "▎" },
					uncovered = { hl = "CoverageUncovered", text = "▎" },
				},
				summary = {
					min_coverage = 80.0,
				},
				lang = {
					python = {
						coverage_command = "coverage json --fail-under=0 -q -o -",
					},
					rust = {
						coverage_command = "grcov . -s . --binary-path ./target/debug/ -t coveralls --branch --ignore-not-existing --token YOUR_COVERALLS_TOKEN -o -",
					},
				},
			})

			vim.keymap.set("n", "<leader>cc", function() require("coverage").load(true) end, { desc = "加载覆盖率" })
			vim.keymap.set("n", "<leader>cs", function() require("coverage").summary() end, { desc = "覆盖率摘要" })
			vim.keymap.set("n", "<leader>ct", function() require("coverage").toggle() end, { desc = "切换覆盖率显示" })
		end,
	},

	-- 项目管理
	{
		"ahmedkhalf/project.nvim",
		config = function()
		require("project_nvim").setup({
			detection_methods = { "lsp", "pattern" },
			patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "Cargo.toml", "pyproject.toml" },
			ignore_lsp = {},
			exclude_dirs = {},
			show_hidden = false,
			silent_chdir = true,
			scope_chdir = 'global',
		})

		-- 使用 telescope 扩展
		pcall(require('telescope').load_extension, 'projects')
		end,
	},
	{
		"brenoprata10/nvim-highlight-colors",
		config = function()
		require("nvim-highlight-colors").setup({
			render = 'background', -- 'background' | 'foreground' | 'virtual'
		enable_named_colors = true,
		enable_tailwind = true,
		})
		end,
	},


	-- 符号大纲
	{
		"simrat39/symbols-outline.nvim",
		config = function()
			require("symbols-outline").setup({
				highlight_hovered_item = true,
				show_guides = true,
				auto_preview = false,
				position = 'right',
				relative_width = true,
				width = 25,
				auto_close = false,
				show_numbers = false,
				show_relative_numbers = false,
				show_symbol_details = true,
				preview_bg_highlight = 'Pmenu',
				autofold_depth = nil,
				auto_unfold_hover = true,
				fold_markers = { '', '' },
				wrap = false,
				keymaps = {
					close = {"<Esc>", "q"},
					goto_location = "<Cr>",
					focus_location = "o",
					hover_symbol = "<C-space>",
					toggle_preview = "K",
					rename_symbol = "r",
					code_actions = "a",
					fold = "h",
					unfold = "l",
					fold_all = "W",
					unfold_all = "E",
					fold_reset = "R",
				},
				lsp_blacklist = {},
				symbol_blacklist = {},
				symbols = {
					File = { icon = "", hl = "@text.uri" },
					Module = { icon = "", hl = "@namespace" },
					Namespace = { icon = "", hl = "@namespace" },
					Package = { icon = "", hl = "@namespace" },
					Class = { icon = "𝓒", hl = "@type" },
					Method = { icon = "ƒ", hl = "@method" },
					Property = { icon = "", hl = "@method" },
					Field = { icon = "", hl = "@field" },
					Constructor = { icon = "", hl = "@constructor" },
					Enum = { icon = "ℰ", hl = "@type" },
					Interface = { icon = "ﰮ", hl = "@type" },
					Function = { icon = "", hl = "@function" },
					Variable = { icon = "", hl = "@constant" },
					Constant = { icon = "", hl = "@constant" },
					String = { icon = "𝓐", hl = "@string" },
					Number = { icon = "#", hl = "@number" },
					Boolean = { icon = "⊨", hl = "@boolean" },
					Array = { icon = "", hl = "@constant" },
					Object = { icon = "⦿", hl = "@type" },
					Key = { icon = "🔐", hl = "@type" },
					Null = { icon = "NULL", hl = "@type" },
					EnumMember = { icon = "", hl = "@field" },
					Struct = { icon = "𝓢", hl = "@type" },
					Event = { icon = "🗲", hl = "@type" },
					Operator = { icon = "+", hl = "@operator" },
					TypeParameter = { icon = "𝙏", hl = "@parameter" },
					Component = { icon = "", hl = "@function" },
					Fragment = { icon = "", hl = "@constant" },
				},
			})

			vim.keymap.set("n", "<leader>so", ":SymbolsOutline<CR>", { desc = "切换符号大纲" })
		end,
	},

	-- 函数签名帮助
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			require('lsp_signature').setup(opts)
		end
	},

	-- 增强的 LSP 体验
	{
		"glepnir/lspsaga.nvim",
		event = "LspAttach",
		config = function()
			require("lspsaga").setup({
				preview = {
					lines_above = 0,
					lines_below = 10,
				},
				scroll_preview = {
					scroll_down = "<C-f>",
					scroll_up = "<C-b>",
				},
				request_timeout = 2000,
				finder = {
					edit = { "o", "<CR>" },
					vsplit = "s",
					split = "i",
					tabe = "t",
					quit = { "q", "<ESC>" },
				},
				definition = {
					edit = "<C-c>o",
					vsplit = "<C-c>v",
					split = "<C-c>i",
					tabe = "<C-c>t",
					quit = "q",
				},
				code_action = {
					num_shortcut = true,
					keys = {
						quit = "q",
						exec = "<CR>",
					},
				},
				lightbulb = {
					enable = true,
					enable_in_insert = true,
					sign = true,
					sign_priority = 40,
					virtual_text = true,
				},
				diagnostic = {
					insert_mode = false,
					jump_num_shortcut = true,
					on_insert = false,
					on_insert_follow = false,
					show_code_action = true,
					show_source = true,
					custom_fix = nil,
					custom_msg = nil,
					text_hl_follow = false,
					border_follow = true,
					keys = {
						exec_action = "o",
						quit = "q",
						go_action = "g"
					},
				},
				rename = {
					quit = "<C-c>",
					exec = "<CR>",
					mark = "x",
					confirm = "<CR>",
					in_select = true,
				},
				outline = {
					win_position = "right",
					win_with = "",
					win_width = 30,
					show_detail = true,
					auto_preview = true,
					auto_refresh = true,
					auto_close = true,
					custom_sort = nil,
					keys = {
						jump = "o",
						expand_collapse = "u",
						quit = "q",
					},
				},
				symbol_in_winbar = {
					enable = true,
					separator = "  ",
					hide_keyword = true,
					show_file = true,
					folder_level = 2,
					respect_root = false,
					color_mode = true,
				},
			})

			-- LSP Saga 快捷键
			vim.keymap.set("n", "<c-ca>", "<cmd>Lspsaga code_action<CR>", { desc = "代码操作" })
			vim.keymap.set("v", "<c-ca>", "<cmd>Lspsaga code_action<CR>", { desc = "代码操作" })
			vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", { desc = "LSP 重命名" })
			vim.keymap.set("n", "gd", "<cmd>Lspsaga lsp_finder<CR>", { desc = "LSP 查找器" })
			vim.keymap.set("n", "gp", "<cmd>Lspsaga preview_definition<CR>", { desc = "预览定义" })
			vim.keymap.set("n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = "显示行诊断" })
			vim.keymap.set("n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { desc = "显示光标诊断" })
			vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "上一个诊断" })
			vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "下一个诊断" })
			vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "悬停文档" })
			vim.keymap.set("n", "<A-d>", "<cmd>Lspsaga term_toggle<CR>", { desc = "切换终端" })
		end,
	},

	-- Markdown 预览和编辑增强
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function() vim.fn["mkdp#util#install"]() end,
		config = function()
			vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", { desc = "切换 Markdown 预览" })
		end,
	},

	-- 高级搜索和替换
	{
		"nvim-pack/nvim-spectre",
		build = false,
		cmd = "Spectre",
		opts = { open_cmd = "noswapfile vnew" },
		keys = {
			{ "<leader>sr", function() require("spectre").open() end, desc = "替换 (Spectre)" },
		},
	},

	-- 更好的快速修复窗口
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		config = function()
			require("bqf").setup({
				auto_enable = true,
				auto_resize_height = true,
				preview = {
					win_height = 12,
					win_vheight = 12,
					delay_syntax = 80,
					border_chars = {"┃", "━", "┏", "┓", "┗", "┛", "┣", "┫", "━", "┃"},
					should_preview_cb = function(bufnr, qwinid)
						local ret = true
						local bufname = vim.api.nvim_buf_get_name(bufnr)
						local fsize = vim.fn.getfsize(bufname)
						if fsize > 100 * 1024 then
							ret = false
						end
						return ret
					end
				},
				func_map = {
					drop = "o",
					openc = "O",
					split = "<C-s>",
					tabdrop = "<C-t>",
					tabc = "",
					ptogglemode = "z,",
				},
				filter = {
					fzf = {
						action_for = {["ctrl-s"] = "split", ["ctrl-t"] = "tab drop"},
						extra_opts = {"--bind", "ctrl-o:toggle-all", "--prompt", "> "}
					}
				}
			})
		end,
	},
})
