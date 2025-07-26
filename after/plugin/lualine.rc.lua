local status, lualine = pcall(require, 'lualine')
if (not status) then return end

lualine.setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch' },
    lualine_c = { {
      'filename',
      file_status = true, -- display file status
      path = 1            -- 0 = just filename
    } },
    lualine_x = {
      {
        'diagnostics', --显示诊断信息，这里相关插件还未配置
        source = { 'nvim_diagnostics' },
        symbols = {
          error = ' ',
          warn = ' ',
          info = ' ',
          hint = ' '
        }
      },
      'encoding',
      'filetype',
    },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
  tabline = {},
  extensions = { 'nvim-tree', 'trouble', 'lazy' } -- Lualine会根据不同的窗口显示不同的插件
}
