local wezterm = require("wezterm")

local SOLID_LEFT_ARROW = utf8.char(0xe0ba)
local SOLID_RIGHT_ARROW = utf8.char(0xe0bc)

local M = {}
M.setup = function()
	wezterm.on("update-right-status", function(window, pane)
		local key_table = window:active_key_table()
		if key_table == nil then
			key_table = " "
		end
		local leader = " leader "
		if window:leader_is_active() == false then
			leader = " "
		end
		local workspace = " " .. wezterm.mux.get_active_workspace() .. " "
		local time = wezterm.strftime '%b %-d %H:%M'

		local ktclr = '#89b4fa'
		local ldclr = '#cba6f7'
		local wsclr = '#a6e3a1'
		local timeclr = '#f9e2af'
		local edgeclr = '#f38ba8'
		local txtclr = '#1f1f28'

		window:set_right_status(wezterm.format({
			{ Foreground = { Color = ktclr } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = ktclr } },
			{ Foreground = { Color = txtclr } },
			{ Text = key_table },
			{ Foreground = { Color = ktclr } },
			{ Text = SOLID_RIGHT_ARROW },
			{ Foreground = { Color = ldclr } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = ldclr } },
			{ Foreground = { Color = txtclr } },
			{ Text = leader },
			{ Foreground = { Color = ldclr } },
			{ Text = SOLID_RIGHT_ARROW },
			{ Foreground = { Color = wsclr } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = wsclr } },
			{ Foreground = { Color = txtclr } },
			{ Text = workspace },
			{ Foreground = { Color = wsclr } },
			{ Text = SOLID_RIGHT_ARROW },
			{ Foreground = { Color = timeclr } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = timeclr } },
			{ Foreground = { Color = txtclr } },
			{ Text = " " .. time },
			{ Foreground = { Color = timeclr } },
			{ Text = SOLID_RIGHT_ARROW },
			{ Foreground = { Color = edgeclr } },
			{ Text = SOLID_LEFT_ARROW },
		}))
	end)
end

return M