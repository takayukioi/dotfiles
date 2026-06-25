local wezterm = require("wezterm")
local platform = require("utils.platform")

local SOLID_LEFT_ARROW = utf8.char(0xe0ba)
local SOLID_RIGHT_ARROW = utf8.char(0xe0bc)

local nf = wezterm.nerdfonts
local OS_ICON_APPLE = nf.dev_apple
local OS_ICON_WINDOWS = nf.dev_windows
local OS_ICON_LINUX = nf.dev_linux
local OS_ICON_FALLBACK = nf.cod_terminal

local BATTERY_CHARGE = utf8.char(0x26a1)
local discharging_icons = {
   nf.md_battery_10,
   nf.md_battery_20,
   nf.md_battery_30,
   nf.md_battery_40,
   nf.md_battery_50,
   nf.md_battery_60,
   nf.md_battery_70,
   nf.md_battery_80,
   nf.md_battery_90,
   nf.md_battery,
}
---@type string[]
local charging_icons = {
   nf.md_battery_charging_10,
   nf.md_battery_charging_20,
   nf.md_battery_charging_30,
   nf.md_battery_charging_40,
   nf.md_battery_charging_50,
   nf.md_battery_charging_60,
   nf.md_battery_charging_70,
   nf.md_battery_charging_80,
   nf.md_battery_charging_90,
   nf.md_battery_charging,
}


---@return string, string
local function battery_info()
   -- ref: https://wezfurlong.org/wezterm/config/lua/wezterm/battery_info.html

   local charge = '100%'
   local icon = nf.md_home_battery

   for _, b in ipairs(wezterm.battery_info()) do
      local idx = umath.clamp(umath.round(b.state_of_charge * 10), 1, 10)
      charge = string.format('%.0f%%', b.state_of_charge * 100)

      if b.state == 'Charging' then
         icon = charging_icons[idx]
      else
         icon = discharging_icons[idx]
      end
   end

   return charge, icon
end

local M = {}
M.setup = function(color)
	wezterm.on("update-right-status", function(window, pane)
		local key_table = window:active_key_table()
		local mode_name

		if window:leader_is_active() == true then
			mode_name = "leader"
		elseif key_table ~= nil then
			mode_name = key_table
		else
			mode_name = " "
		end

		local workspace = wezterm.mux.get_active_workspace()
		local time = wezterm.strftime("%b %-d %H:%M")

		local os_icon
		if platform.is_win then
			os_icon = OS_ICON_WINDOWS
		elseif platform.is_linux then
			os_icon = OS_ICON_LINUX
		elseif platform.is_mac then
			os_icon = OS_ICON_APPLE
		else
			os_icon = OS_ICON_FALLBACK
		end

		local battery_text, battery_icon = battery_info()

		local ktclr = color.bright.blue
		local ldclr = color.ansi.magenta
		local wsclr = color.bright.green
		local timeclr = color.bright.yellow
		local edgeclr = color.peachRed
		local txtclr = color.background

		window:set_right_status(wezterm.format({
			{Attribute={Intensity="Bold"}},
			{ Foreground = { Color = ktclr } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = ktclr } },
			{ Foreground = { Color = txtclr } },
			{ Text = " " .. string.upper(mode_name) .. " " },

			{ Foreground = { Color = ldclr } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = ldclr } },
			{ Foreground = { Color = txtclr } },
			{ Text = " " .. battery_text .. " " .. battery_icon .. " " },

			{ Foreground = { Color = wsclr } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = wsclr } },
			{ Foreground = { Color = txtclr } },
			{ Text = " " .. workspace .. " " },

			{ Foreground = { Color = timeclr } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = timeclr } },
			{ Foreground = { Color = txtclr } },
			{ Text = " " .. time .. " " },

			{ Foreground = { Color = edgeclr } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = edgeclr } },
			{ Foreground = { Color = txtclr } },
			{ Text = " " .. os_icon .. " " },
		}))
	end)
end


return M
