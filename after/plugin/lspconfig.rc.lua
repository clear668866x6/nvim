-- ~/.config/nvim/lua/config/lsp.lua (已更新以配合 tiny-inline-diagnostic.nvim)

local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local diagnostics = vim.diagnostic

--------------------------------------------------------------------------------
-- 基础诊断配置
--------------------------------------------------------------------------------

-- 配置诊断显示和符号
diagnostics.config({
  -- 定义左侧Gutter中的诊断符号
  signs = {
    text = {
      [diagnostics.severity.ERROR] = "",
      [diagnostics.severity.WARN] = "",
      [diagnostics.severity.INFO] = "",
      [diagnostics.severity.HINT] = "",
    },
  },

  -- 【重要】禁用默认的行尾虚拟文本，因为我们将使用 tiny-inline-diagnostic.nvim 插件
  virtual_text = false,

  underline = true, -- 在错误下显示下划线
  update_in_insert = true,
  severity_sort = true, -- 按严重程度排序
  float = { -- 悬停诊断信息 (用 <leader>e 查看)
    border = "rounded",
    source = "always", -- 显示错误来源
    header = "",
    prefix = function(diag)
      local icons = {
        [diagnostics.severity.ERROR] = " ",
        [diagnostics.severity.WARN]  = " ",
        [diagnostics.severity.INFO]  = " ",
        [diagnostics.severity.HINT]  = " ",
      }
      return icons[diag.severity]
    end,
  },
})


--------------------------------------------------------------------------------
-- LSP 基础配置
--------------------------------------------------------------------------------

-- 创建 LSP 快捷键映射
local function create_lsp_keymaps(bufnr)
  local map = function(keys, func, desc)
    vim.keymap.set(
      'n',
      keys,
      func,
      { buffer = bufnr, noremap = true, silent = true, desc = 'LSP: ' .. desc }
    )
  end

  -- 核心快捷键 (通用LSP功能)
  map('gd', vim.lsp.buf.definition, '跳转到定义')
  map('K', vim.lsp.buf.hover, '显示悬停文档')
  map('<leader>rn', vim.lsp.buf.rename, '重命名符号')
  map('<leader>ca', vim.lsp.buf.code_action, '代码操作')
  map('gr', require('telescope.builtin').lsp_references, '查找引用')

  --- 为函数签名帮助添加手动触发快捷键
  map('<C-s>', vim.lsp.buf.signature_help, '显示函数签名')

  -- 诊断导航
  map(']d', diagnostics.goto_next, '下一个诊断')
  map('[d', diagnostics.goto_prev, '上一个诊断')
  map('<leader>e', diagnostics.open_float, '查看诊断详情')
end

-- LSP 客户端附加时的回调
local function on_attach(client, bufnr)
  -- 启用代码补全
  if client.server_capabilities.completionProvider then
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  end

  -- 创建快捷键映射
  create_lsp_keymaps(bufnr)

  -- 启用文档高亮
  if client.server_capabilities.documentHighlightProvider then
    vim.cmd([[
      augroup document_highlight
      autocmd! * <buffer>
      autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
      autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]])
  end

  if client.server_capabilities.signatureHelpProvider then
    local signature_group = vim.api.nvim_create_augroup('LspSignature', { clear = true })
    vim.api.nvim_create_autocmd('TextChangedI', {
      group = signature_group,
      buffer = bufnr,
      callback = function()
        pcall(vim.lsp.buf.signature_help)
      end
    })
  end
end

--------------------------------------------------------------------------------
-- 自动命令组：基础 LSP 体验
--------------------------------------------------------------------------------
vim.api.nvim_create_augroup("lsp_diagnostics", { clear = true })
vim.api.nvim_create_autocmd("CursorHold", {
  group = "lsp_diagnostics",
  callback = function()
    diagnostics.open_float(nil, { focusable = false })
  end
})

-- 更美观的悬停诊断窗口
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
