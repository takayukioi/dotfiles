local wezterm = require("wezterm")
local platform = require("utils.platform")

local SOLID_LEFT_ARROW = utf8.char(0xe0ba)

local nf = wezterm.nerdfonts
local OS_ICON_CAL = nf.fa_calendar
local OS_ICON_WS = nf.fa_layer_group

local M = {}
M.setup = function(color)
	wezterm.on("update-right-status", function(window, pane)
		local key_table = window:active_key_table()
		local mode_name

		local normal_color = color.ansi.blue
		local copy_mode_color = color.ansi.magenta
		local pane_size_color = color.bright.green
		local leader_color = color.peachRed

		local mode_bg = normal_color
		if window:leader_is_active() == true then
			mode_name = "leader"
			mode_bg = leader_color
		elseif key_table ~= nil then
			mode_name = key_table
			if key_table == "copy_mode" then
				mode_bg = copy_mode_color
			elseif key_table == "resize_pane" then
				mode_bg = pane_size_color
			end
		else
			mode_name = "NORMAL"
		end

		local base_color = wezterm.color.parse(mode_bg)
		local text_bg = base_color:lighten(0.6)

		local workspace = wezterm.mux.get_active_workspace()
		local time = wezterm.strftime("%b %-d %H:%M")

		window:set_right_status(wezterm.format({
			{ Foreground = { Color = text_bg } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = text_bg } },
			{ Foreground = { Color = color.background } },
			{ Text = "  " .. OS_ICON_WS .. " " },
			{ Text = workspace .. " " },
			{ Text = "  " .. OS_ICON_CAL .. " " },
			{ Text = time .. "  " },

			{ Foreground = { Color = mode_bg } },
			{ Text = SOLID_LEFT_ARROW },

			{ Background = { Color = mode_bg } },
			{ Foreground = { Color = color.background } },
			{ Text = "  " .. string.upper(mode_name) .. " " },
		}))
	end)
end

return M
