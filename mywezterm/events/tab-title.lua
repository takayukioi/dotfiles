local wezterm = require("wezterm")

      -- The filled in variant of the < symbol
      local SOLID_LEFT_ARROW = utf8.char(0xe0ba)
      local SOLID_LEFT_MOST = utf8.char(0x2588)

      -- The filled in variant of the > symbol
      local SOLID_RIGHT_ARROW = utf8.char(0xe0bc)

local M = {}
M.setup = function()
wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)

      local edge_background = "#121212"
      local background = "#4E4E4E"
      local foreground = "#1C1B19"
      local dim_foreground = "#3A3A3A"

      if tab.is_active then
         background = "#FBB829"
         foreground = "#1C1B19"
      elseif hover then
         background = "#FF8700"
         foreground = "#1C1B19"
      end

      local edge_foreground = background
      local clean_title = tab_title(tab)
      local title = " " .. wezterm.truncate_right(clean_title, max_width) .. " "
      local left_arrow = SOLID_LEFT_ARROW
      if tab.tab_index == 0 then
         left_arrow = SOLID_LEFT_MOST
      end
      return {
         { Attribute = { Intensity = "Bold" } },
         { Background = { Color = edge_background } },
         { Foreground = { Color = edge_foreground } },
         { Text = left_arrow },
         { Background = { Color = background } },
         { Foreground = { Color = foreground } },
         { Text = title },
         { Background = { Color = edge_background } },
         { Foreground = { Color = edge_foreground } },
         { Text = SOLID_RIGHT_ARROW },
         { Attribute = { Intensity = "Normal" } },
      }
  end
)
end

function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

return M
