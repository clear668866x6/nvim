-- ~/.config/nvim/lua/config/cmp.lua

local cmp = require('cmp')
local luasnip = require('luasnip')
local lspkind = require('lspkind')

require("luasnip.loaders.from_vscode").lazy_load()

require("luasnip.loaders.from_lua").load({ paths = { "~/.config/nvim/snippets" } })
-- nvim-cmp 设置 (针对普通编辑模式)
cmp.setup({
	-- 指定代码片段引擎
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},

	-- 快捷键映射
	mapping = cmp.mapping.preset.insert({
		['<C-k>'] = cmp.mapping.select_prev_item(),
		['<C-j>'] = cmp.mapping.select_next_item(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
		['<Tab>'] = cmp.mapping(function(fallback)
			if luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),

	-- 补全源
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
		{ name = 'buffer' },
		{ name = 'path' },
	}),

	-- 菜单格式化
	formatting = {
		format = lspkind.cmp_format({
			mode = 'symbol_text',
			maxwidth = 50,
			menu = {
				nvim_lsp = "[LSP]",
				luasnip = "[Snippet]",
				buffer = "[Buffer]",
				path = "[Path]",
			}
		})
	},

	-- 补全窗口边框
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
})

-- 命令行模式需要独立的 cmp 设置
-- 当你输入 ':' 或 '/' 进入命令行时，此设置将生效

cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline({
		-- 这里可以自定义命令行模式下的快捷键
		['<C-k>'] = cmp.mapping.select_prev_item(),
		['<C-j>'] = cmp.mapping.select_next_item(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
		['<Tab>'] = cmp.mapping(function(fallback)
        -- 如果补全菜单可见，就确认选择
        if cmp.visible() then
            cmp.confirm({ select = true })
        -- 如果菜单不可见，就调用 fallback 函数
        -- 在命令行模式下，fallback 会触发默认的补全行为，也就是 `cmp.complete()`
        else
            fallback()
        end
    end, { "c" }), -- "c" 代表 command-line mode
	}),
	sources = cmp.config.sources({
		-- 搜索历史记录
		{ name = 'history' }
	}, {
		-- 当前缓冲区的内容
		{ name = 'buffer' }
	})
})

cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline({
		-- 这里可以自定义命令行模式下的快捷键
		['<C-k>'] = cmp.mapping.select_prev_item(),
		['<C-j>'] = cmp.mapping.select_next_item(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
		['<Tab>'] = cmp.mapping(function(fallback)
        -- 如果补全菜单可见，就确认选择
        if cmp.visible() then
            cmp.confirm({ select = true })
        -- 如果菜单不可见，就调用 fallback 函数
        -- 在命令行模式下，fallback 会触发默认的补全行为，也就是 `cmp.complete()`
        else
            fallback()
        end
    end, { "c" }), -- "c" 代表 command-line mode
	}),
	sources = cmp.config.sources({
		-- Neovim 命令
		{ name = 'cmdline' }
	}, {
		-- 文件路径
		{ name = 'path' }
	})
})
