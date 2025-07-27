local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local diagnostics = vim.diagnostic

local USE_TINY_INLINE = false
local USE_NATIVE_VIRTUAL_TEXT = true

if USE_TINY_INLINE then
  local tiny_inline_diagnostic = require('tiny-inline-diagnostic')
  tiny_inline_diagnostic.setup({
    signs = {
      left = "",
      right = "",
      diag = "●",
      arrow = "    ",
      up_arrow = "    ",
      vertical = " │",
      vertical_end = " └"
    },
    hi = {
      error = "DiagnosticError",
      warn = "DiagnosticWarn",
      info = "DiagnosticInfo",
      hint = "DiagnosticHint",
      arrow = "NonText",
      background = "CursorLine",
    },
    blend = {
      factor = 0.27,
    },
    options = {
      show_source = false,
      throttle = 20,
      softwrap = 15,
      multiple_diag_under_cursor = true, -- 在同一行显示多个诊断
      overflow = {
        mode = "wrap",
      },
      format = function(diagnostic)
        return diagnostic.message
      end,
      enable_on_insert = true,
      show_diag_on_hover = false,
    }
  })
end

diagnostics.config({
  signs = {
    text = {
      [diagnostics.severity.ERROR] = "●",
      [diagnostics.severity.WARN] = "●",
      [diagnostics.severity.INFO] = "●",
      [diagnostics.severity.HINT] = "●",
    },
  },

  virtual_text = USE_NATIVE_VIRTUAL_TEXT and {
    severity = { min = vim.diagnostic.severity.HINT }, -- 显示所有级别
    source = "if_many", -- 显示来源
    prefix = function(diagnostic)
    local icons = {
      [diagnostics.severity.ERROR] = "●",
      [diagnostics.severity.WARN] = "●",
      [diagnostics.severity.INFO] = "●",
      [diagnostics.severity.HINT] = "●",
      }
      return icons[diagnostic.severity]
    end,
    format = function(diagnostic)
      return string.format(" %s", diagnostic.message)
    end,
    -- 实时更新
    spacing = 2,
  } or false,

  underline = true,
  update_in_insert = true,
  severity_sort = true, -- 按严重程度排序
  float = { -- 悬停诊断信息 (用 <leader>e 查看)
    border = "rounded",
    source = "always", -- 显示错误来源
    header = "",
    prefix = function(diag)
    local icons = {
      [diagnostics.severity.ERROR] = "●",
      [diagnostics.severity.WARN] = "●",
      [diagnostics.severity.INFO] = "●",
      [diagnostics.severity.HINT] = "●",
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

  local diag_group = vim.api.nvim_create_augroup('RealTimeDiagnostics', { clear = true })

  vim.api.nvim_create_autocmd({'TextChangedI'}, {
    group = diag_group,
    buffer = bufnr,
    callback = function()
      -- 立即刷新诊断，不延迟
      vim.diagnostic.show(nil, bufnr)
      -- 同时触发 LSP 诊断
      vim.defer_fn(function()
        -- 强制 LSP 重新分析
        if client.server_capabilities.documentDiagnosticProvider then
          vim.lsp.buf.document_diagnostics()
        end
      end, 50) -- 减少延迟到 50ms
    end
  })

  vim.api.nvim_create_autocmd({'TextChanged'}, {
    group = diag_group,
    buffer = bufnr,
    callback = function()
      vim.diagnostic.show(nil, bufnr)
      -- 立即请求新的诊断
      vim.defer_fn(function()
        if client.server_capabilities.documentDiagnosticProvider then
          vim.lsp.buf.document_diagnostics()
        end
      end, 50)
    end
  })

  vim.api.nvim_create_autocmd({'TextChangedP'}, {
    group = diag_group,
    buffer = bufnr,
    callback = function()
      vim.diagnostic.show(nil, bufnr)
    end
  })

  vim.api.nvim_create_autocmd({'BufEnter', 'WinEnter'}, {
    group = diag_group,
    buffer = bufnr,
    callback = function()
      vim.diagnostic.show(nil, bufnr)
    end
  })

  vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
    group = diag_group,
    buffer = bufnr,
    callback = function()
      vim.diagnostic.show(nil, bufnr)
    end
  })
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

-- 【调试用】添加一个命令来检查诊断状态
vim.api.nvim_create_user_command('DiagnosticDebug', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics_list = vim.diagnostic.get(bufnr)
  print("当前缓冲区诊断数量: " .. #diagnostics_list)
  for i, diag in ipairs(diagnostics_list) do
    print(string.format("诊断 %d: 行 %d, 严重程度 %d, 消息: %s",
      i, diag.lnum + 1, diag.severity, diag.message))
  end
  -- 检查 signcolumn 设置
  print("signcolumn 设置: " .. vim.o.signcolumn)
  -- 检查诊断配置
  local config = vim.diagnostic.config()
  print("signs 配置: " .. vim.inspect(config.signs))
end, {})

lspconfig.pyright.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        -- 启用实时类型检查
        typeCheckingMode = "basic", -- 或 "strict"
        -- 自动导入建议
        autoImportCompletions = true,
        -- 启用所有诊断
        diagnosticMode = "workspace", -- 检查整个工作区
      }
    }
  },
  flags = {
    debounce_text_changes = 50, -- 50ms 延迟而不是默认的 150ms
  }
})

-- Rust
lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      -- 启用实时诊断
      checkOnSave = {
        command = "check" -- 或 "clippy" 获得更多诊断
      },
      -- 实时类型推断
      inlayHints = {
        enable = true,
      },
      -- 诊断配置
      diagnostics = {
        enable = true,
        enableExperimental = true,
      }
    }
  },
  flags = {
    debounce_text_changes = 50, -- 50ms 延迟
  }
})
