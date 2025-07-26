local is_picking_focus = require("cokeline/mappings").is_picking_focus
local is_picking_close = require("cokeline/mappings").is_picking_close

local red = vim.g.terminal_color_1
local yellow = vim.g.terminal_color_4
local space = { text = " " }
local high = "#63f2f1"
local light = '#f3f3f3'
local text = "#f3f3f3"
local grey = "#2d2b40"
local dark = "#1d1b2f"

local function get_path_parts(path)
  local dirs = {}
  for dir in string.gmatch(path, "([^/]+)") do
    table.insert(dirs, dir)
  end

  local filename = dirs[#dirs]
  if filename ~= nil and string.sub(filename, 1, 1) == "+" then
    local ext = filename:match("^.+(%..+)$")
    local last_dir = dirs[#dirs - 1]
    if last_dir == '[id]' and path:match('api') and filename == "+server.ts" then
      local id_index = 0
      for i, dir in ipairs(dirs) do
        if dir == "[id]" then
          id_index = i
        end
      end
      local new_dir = dirs[id_index - 1]
      return new_dir .. "/[id]/" .. filename
    elseif last_dir == '[id]' then
      local id_index = 0
      for i, dir in ipairs(dirs) do
        if dir == "[id]" then
          id_index = i
        end
      end
      local new_dir = dirs[id_index - 1]
      return new_dir .. "/[id]/" .. filename
    elseif
        path:match("api") then
      local api_index = 0
      for i, dir in ipairs(dirs) do
        if dir == "api" then
          api_index = i
        end
      end
      local api_next_dir = dirs[api_index + 1]
      return "api/" .. api_next_dir .. '/' .. filename
    elseif ext == nil then
      local dir = dirs[#dirs - 1]
      return dir .. "/" .. filename
    else
      local dir = dirs[#dirs - 1]
      return dir .. "/" .. filename
    end
  end
end

require("cokeline").setup(
  {
    sidebar = {
      filetype = 'NvimTree',
      components = {
        {
          text = "  NvimTree",
          fg = dark,
          bg = high,
          style = 'bold'
        } }
    },
    default_hl = {
      fg = function(buffer)
        if buffer.is_focused then
          return dark
        end
        return text
      end,
      bg = function(buffer)
        if buffer.is_focused then
          return high
        end
        return grey
      end
    },
    components = {
      {
        text = function(buffer)
          if buffer.index ~= 1 then
            return ""
          end
          return ""
        end,
        bg = function(buffer)
          if buffer.is_focused then
            return high
          end
          return grey
        end,
        fg = dark
      },
      space,
      {
        text = function(buffer)
          if is_picking_focus() or is_picking_close() then
            return buffer.pick_letter .. " "
          end

          return buffer.devicon.icon
        end,
        fg = function(buffer)
          if is_picking_focus() then
            return yellow
          end
          if is_picking_close() then
            return red
          end

          if buffer.is_focused then
            return dark
          else
            return light
          end
        end,
        style = function(_)
          return (is_picking_focus() or is_picking_close()) and "italic,bold" or nil
        end
      },
      {
        text = function(buffer)
          if get_path_parts(buffer.path) ~= nil then
            return get_path_parts(buffer.path) .. "⠀"
          else
           return buffer.unique_prefix .. buffer.filename .. "⠀"
          end
        end,
        style = function(buffer)
          return buffer.is_focused and "bold" or nil
        end
      },
      {
        text = "",
        fg = function(buffer)
          if buffer.is_focused then
            return high
          end
          return grey
        end,
        bg = function()
          local success, normal_hl = pcall(vim.api.nvim_get_hl_by_name, 'Normal', true)
          if success and normal_hl and normal_hl.background then
            return string.format("#%06x", normal_hl.background)
          end
          return light
        end
      }
    }
  }
)
