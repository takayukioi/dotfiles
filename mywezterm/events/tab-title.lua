local wezterm = require("wezterm")

      -- The filled in variant of the < symbol
      local SOLID_LEFT_ARROW = utf8.char(0xe0ba)
      local SOLID_LEFT_MOST = utf8.char(0x2588)

      -- The filled in variant of the > symbol
      local SOLID_RIGHT_ARROW = utf8.char(0xe0bc)

   -- カレントディレクトリを保持するキャッシュテーブル
local cwd_cache = {}
local M = {}
M.setup = function()


-- 1. update-status イベントでCWDを定期的に取得してキャッシュに保存
wezterm.on('update-status', function(window, pane)
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    -- URLオブジェクトからファイルパスを抽出し、末尾のディレクトリ名だけを取得
    local full_path = string.gsub(cwd_uri.file_path, "/+$", "")
    local dir_name = full_path:match("([^/]+)$") or full_path
    
    -- pane_id をキーにしてディレクトリ名を保存
    cwd_cache[pane:pane_id()] = dir_name
  end
end)

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)

      local edge_background = "#1f1f28"
      local background = "#727169"
      local foreground = "#1f1f28"

      if tab.is_active then
         background = "#e6c384"
         foreground = "#1f1f28"
      elseif hover then
         background = "#e0a330"
         foreground = "#1f1f28"
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
  local pane_id = tab_info.active_pane.pane_id
  local dir_name = cwd_cache[pane_id] or tab_info.active_pane.title
  
  local title = tab_info.tab_title
  if dir_name and #dir_name > 0 then
   title = string.format(" %d. %s ", tab_info.tab_index + 1, dir_name)
  end

  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

return M
