-- ~/.config/nvim/lua/config/cmp.lua

local cmp = require('cmp')
local luasnip = require('luasnip')
local lspkind = require('lspkind')

-- ===================================================================
-- [核心] 加载代码片段 (已修正调用方式)
-- ===================================================================
-- 1. 加载来自 friendly-snippets 的预设片段
--    正确方式：直接 require 加载器
require("luasnip.loaders.from_vscode").lazy_load()

-- 2. 加载你自己的自定义片段
--    正确方式：直接 require 加载器，并调用它的 load 函数
--    我们将扫描 ~/.config/nvim/snippets 目录下的所有 .lua 文件
require("luasnip.loaders.from_lua").load({ paths = { "~/.config/nvim/snippets" } })
-- ===================================================================


-- nvim-cmp 设置 (这部分你的配置已经很完美，无需改动)
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
