
local colors = {
  blue   = '#80a0ff',
  cyan   = '#79dac8',
  black  = '#080808',
  white  = '#c6c6c6',
  red    = '#ff5189',
  violet = '#d183e8',
  grey   = '#303030',
  -- 诊断颜色
  error  = '#ff5189',
  warn   = '#f0c674',
  info   = '#0db9d7',
  hint   = '#10b981',
}

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = "auto",
    component_separators = '',
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = {
      { 'mode', separator = { left = ''  }, right_padding = 2 }
    },
    lualine_b = {
      { 'branch', icon = '' },
      { 'filename', icon = '' },
    },
    lualine_c = {
      '%=',
    },
    lualine_x = {
      {
        'diagnostics',
        sources = { 'nvim_diagnostic', 'nvim_lsp' },
        sections = { 'error', 'warn', 'info', 'hint' },
        diagnostics_color = {
          error = { fg = colors.error },
          warn  = { fg = colors.warn },
          info  = { fg = colors.info },
          hint  = { fg = colors.hint },
        },
        symbols = {
          error = ' ',
          warn  = ' ',
          info  = ' ',
          hint  = '💡',
        },
        colored = true,
        update_in_insert = true,
        always_visible = false,
      },
      {
        function()
        local msg = 'No Active Lsp'
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if next(clients) == nil then
          return msg
          end
          local client_names = {}
          for _, client in ipairs(clients) do
            table.insert(client_names, client.name)
            end
            return table.concat(client_names, ', ')
            end,
            icon = ' ',
            color = { fg = colors.white, gui = 'bold' },
      }
    },
    lualine_y = {
      { 'filetype', icon = '' },
      { 'progress', icon = '' },
    },
    lualine_z = {
      { 'location', icon = '', separator = { right =  ''  }, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = { 'filename' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'location' },
  },
  tabline = {},
  extensions = {},
}

vim.api.nvim_create_augroup("LualineDiagnostics", { clear = true })
vim.api.nvim_create_autocmd({ "DiagnosticChanged", "LspAttach", "LspDetach" }, {
  group = "LualineDiagnostics",
  callback = function()
  -- 强制刷新 lualine 显示
  require('lualine').refresh()
  end,
})
