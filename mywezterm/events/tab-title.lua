local wezterm = require("wezterm")

-- tab icons
local TAB_ICON_DOCKER = wezterm.nerdfonts.md_docker
local TAB_ICON_PYTHON = wezterm.nerdfonts.dev_python
local TAB_ICON_NEOVIM = wezterm.nerdfonts.linux_neovim
local TAB_ICON_ZSH = wezterm.nerdfonts.dev_terminal
local TAB_ICON_TASK = wezterm.nerdfonts.cod_server_process
local TAB_ICON_NODE = wezterm.nerdfonts.md_language_typescript
local TAB_ICON_RAILS = wezterm.nerdfonts.dev_rails
local TAB_ICON_FALLBACK = wezterm.nerdfonts.md_console_line

-- tab icon colors
local TAB_ICON_COLOR_DOCKER = "#4169e1"
local TAB_ICON_COLOR_PYTHON = "#ffd700"
local TAB_ICON_COLOR_NEOVIM = "#32cd32"
local TAB_ICON_COLOR_ZSH = "#1d5f7a"
local TAB_ICON_COLOR_TASK = "#ff7f50"
local TAB_ICON_COLOR_NODE = "#339933"
local TAB_ICON_COLOR_RAILS = "#cc0000"
local TAB_ICON_COLOR_FALLBACK = "#090618"

local cwd_cache = {}
function get_icon(tab_info)
	local icon = TAB_ICON_FALLBACK
	local icon_foreground = TAB_ICON_COLOR_FALLBACK
	if tab_info.active_pane.title == "nvim" then
		icon = TAB_ICON_NEOVIM
		icon_foreground = TAB_ICON_COLOR_NEOVIM
	elseif tab_info.active_pane.title == "zsh" then
		icon = TAB_ICON_ZSH
		icon_foreground = TAB_ICON_COLOR_ZSH
	elseif tab_info.active_pane.title == "Python" or string.find(tab_info.active_pane.title, "python") then
		icon = TAB_ICON_PYTHON
		icon_foreground = TAB_ICON_COLOR_PYTHON
	elseif tab_info.active_pane.title == "node" or string.find(tab_info.active_pane.title, "node") then
		icon = TAB_ICON_NODE
		icon_foreground = TAB_ICON_COLOR_NODE
	elseif tab_info.active_pane.title == "docker" or string.find(tab_info.active_pane.title, "docker") then
		icon = TAB_ICON_DOCKER
		icon_foreground = TAB_ICON_COLOR_DOCKER
	elseif tab_info.active_pane.title == "task" or string.find(tab_info.active_pane.title, "task") then
		icon = TAB_ICON_TASK
		icon_foreground = TAB_ICON_COLOR_TASK
	elseif tab_info.active_pane.title == "rails" or string.find(tab_info.active_pane.title, "rails") then
		icon = TAB_ICON_RAILS
		icon_foreground = TAB_ICON_COLOR_RAILS
	end
	return {
		icon = icon,
		foreground = icon_foreground,
	}
end
function tab_title(tab_info)
  	local pane_id = tab_info.active_pane.pane_id
	local dir_name = cwd_cache[pane_id] or tab_info.active_pane.title

	local title = tab_info.tab_title
	if dir_name and #dir_name > 0 then
		title = string.format(" %s ", dir_name)
	end

	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = utf8.char(0xe0ba)
local SOLID_LEFT_MOST = utf8.char(0x2588)

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = utf8.char(0xe0bc)

local M = {}
M.setup = function(color)
	-- 1. update-status イベントでCWDを定期的に取得してキャッシュに保存
	wezterm.on("update-status", function(window, pane)
		local cwd_uri = pane:get_current_working_dir()
		if cwd_uri then
			-- URLオブジェクトからファイルパスを抽出し、末尾のディレクトリ名だけを取得
			local full_path = string.gsub(cwd_uri.file_path, "/+$", "")
			local dir_name = full_path:match("([^/]+)$") or full_path

			-- pane_id をキーにしてディレクトリ名を保存
			cwd_cache[pane:pane_id()] = dir_name
		end
	end)

	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		local edge_background = color.background
		local background = color.bright.black
		local foreground = color.background

		if tab.is_active then
			background = color.bright.yellow
			foreground = color.background
		elseif hover then
			background = "#e0a330"
			foreground = color.background
		end

		local edge_foreground = background
		local icon_info = get_icon(tab)
		local clean_title = tab_title(tab)
		local title = wezterm.truncate_right(clean_title, max_width)
		local left_arrow = SOLID_LEFT_ARROW
		if tab.tab_index == 0 then
			left_arrow = SOLID_LEFT_MOST
		end
		return {
			{ Attribute = { Intensity = "Bold" } },
			{ Background = { Color = edge_background } },
			{ Foreground = { Color = edge_foreground } },
			{ Text = left_arrow },
			{ Foreground = { Color = icon_info.foreground } },
			{ Background = { Color = background } },
    { Text = " " .. icon_info.icon },
			{ Background = { Color = background } },
			{ Foreground = { Color = foreground } },
			{ Text = title .. " " },
			{ Background = { Color = edge_background } },
			{ Foreground = { Color = edge_foreground } },
			{ Text = SOLID_RIGHT_ARROW },
			{ Attribute = { Intensity = "Normal" } },
		}
	end)
end

return M
