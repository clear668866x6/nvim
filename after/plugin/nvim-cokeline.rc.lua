local cokeline = require('cokeline')
local get_hl_attr = require('cokeline.hlgroups').get_hl_attr

local function get_color(group, attr, fallback)
local color = get_hl_attr(group, attr)
return color or (fallback and get_hl_attr(fallback, attr))
end

-- 基础颜色
local editor_bg = function() return get_color('Normal', 'bg') end
local sidebar_bg = function() return get_color('NvimTreeNormal', 'bg', 'Normal') end

-- 标签颜色
local focused_fg = function() return get_color('Normal', 'fg') end
local focused_bg = function() return get_color('Visual', 'bg') end
local unfocused_fg = function() return get_color('Comment', 'fg') end
local unfocused_bg = function() return get_color('TabLineFill', 'bg', 'Normal') end

local pick_fg = '#ffffff'
local pick_bg = '#e32636'

cokeline.setup({
sidebar = {
  filetype = { 'NvimTree', 'neo-tree' },
  components = {
    {
      text = '',
      fg = unfocused_fg,
      bg = sidebar_bg,
    },
    {
      text = function(buf) return ' ' .. buf.filetype .. ' ' end,
               fg = unfocused_fg,
               bg = sidebar_bg,
               bold = true,
    },
  }
},

-- 核心组件配置
components = {
  -- 左侧圆角
  {
    text = '',
    fg = function(buffer)
    return buffer.is_focused and focused_bg() or unfocused_bg()
    end,
    bg = editor_bg,
  },

  -- 图标
  {
    text = function(buffer)
    return ' ' .. buffer.devicon.icon .. ' '
end,
fg = function(buffer)
return buffer.devicon.color
end,
bg = function(buffer)
return buffer.is_focused and focused_bg() or unfocused_bg()
end,
  },

  {
    text = function(buffer)
    return buffer.unique_prefix .. buffer.filename
    end,
    fg = focused_fg,
    bg = function(buffer)
    return buffer.is_focused and focused_bg() or unfocused_bg()
    end,
    bold = function(buffer)
    return buffer.is_focused
    end,
    on_drag = cokeline.move_buffer,
  },

  {
    text = function(buffer)
    if buffer.is_modified then
      return ' ●'
end
return ''
end,
fg = focused_fg,
bg = function(buffer)
return buffer.is_focused and focused_bg() or unfocused_bg()
end,
  },

  {
    text = ' ',
    bg = function(buffer)
    return buffer.is_focused and focused_bg() or unfocused_bg()
    end,
  },

  {
    text = '', -- 关闭图标
    on_click = function(_, _, _, _, buffer)
    buffer:delete()
    end,
    fg = focused_fg,
    bg = function(buffer)
    return buffer.is_focused and focused_bg() or unfocused_bg()
    end,
    pick = {
      fg = pick_fg,
      bg = pick_bg,
      bold = true,
    },
  },

  -- 右侧圆角
  {
    text = '',
    fg = function(buffer)
    return buffer.is_focused and focused_bg() or unfocused_bg()
    end,
    bg = editor_bg,
  },

  {
    text = ' ',
    bg = editor_bg,
  },
},
})
