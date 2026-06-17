local wezterm = require("wezterm")
local platform = require("utils.platform")
local workspace = require("utils.workspace")

require('events.tab-title').setup()
require('events.right-status').setup()

require('utils.backdrops')
   :scan_images_dir()
   :random()

-- === Appearance ===
local gpu_adapters = require("utils.gpu-adapter")
local backdrops = require("utils.backdrops")
local colors = require("colors.kanagawa").colors
local appearance = {
	max_fps = 120,
	front_end = "WebGpu", ---@type 'WebGpu' | 'OpenGL' | 'Software'
	webgpu_power_preference = "HighPerformance",
	webgpu_preferred_adapter = gpu_adapters:pick_best(),
	underline_thickness = "1.5pt",

	-- cursor
	animation_fps = 120,
	cursor_blink_ease_in = "EaseOut",
	cursor_blink_ease_out = "EaseOut",
	default_cursor_style = "BlinkingBlock",
	cursor_blink_rate = 650,

	-- color scheme
	colors = colors,
   -- color_scheme = 'kanagawabones',

	-- background: pass in `true` if you want wezterm to start with focus mode on (no bg images)
	background = backdrops:initial_options({ no_img = false }),

	-- scrollbar
	enable_scroll_bar = true,

	-- tab bar
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = false,
	use_fancy_tab_bar = false,
	tab_max_width = 30,
	show_tab_index_in_tab_bar = false,
	switch_to_last_active_tab_when_closing_tab = true,

	-- command palette
	command_palette_fg_color = "#b4befe",
	command_palette_bg_color = "#11111b",
	command_palette_font_size = 12,
	command_palette_rows = 25,

	-- window
	window_padding = {
		left = 0,
		right = 0,
		top = 10,
		bottom = 7.5,
	},
	adjust_window_size_when_changing_font_size = false,
	window_close_confirmation = "NeverPrompt",
	window_frame = {
		active_titlebar_bg = "#090909",
	},
	inactive_pane_hsb = {
	   saturation = 0.3,
	   brightness = 0.3,
	},

	visual_bell = {
		fade_in_function = "EaseIn",
		fade_in_duration_ms = 250,
		fade_out_function = "EaseOut",
		fade_out_duration_ms = 250,
		target = "CursorColor",
	},
}

-- === Fonts ===
local font_family = "UDEV Gothic 35NFLG" --'JetBrainsMono Nerd Font'
local font_size = platform.is_mac and 20 or 16
local fonts = {
	font = wezterm.font({
		family = font_family,
		weight = "Medium",
	}),
	font_size = font_size,

	--ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
	freetype_load_target = "Normal", ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
	freetype_render_target = "Normal", ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}

-- === General ===
local general = {
	-- behaviours
	automatically_reload_config = true,
	exit_behavior = "CloseOnCleanExit", -- if the shell program exited with a successful status
	exit_behavior_messaging = "Verbose",
	status_update_interval = 1000,

	scrollback_lines = 20000,

	hyperlink_rules = {
		-- Matches: a URL in parens: (URL)
		{
			regex = "\\((\\w+://\\S+)\\)",
			format = "$1",
			highlight = 1,
		},
		-- Matches: a URL in brackets: [URL]
		{
			regex = "\\[(\\w+://\\S+)\\]",
			format = "$1",
			highlight = 1,
		},
		-- Matches: a URL in curly braces: {URL}
		{
			regex = "\\{(\\w+://\\S+)\\}",
			format = "$1",
			highlight = 1,
		},
		-- Matches: a URL in angle brackets: <URL>
		{
			regex = "<(\\w+://\\S+)>",
			format = "$1",
			highlight = 1,
		},
		-- Then handle URLs not wrapped in brackets
		{
			regex = "\\b\\w+://\\S+[)/a-zA-Z0-9-]+",
			format = "$0",
		},
		-- implicit mailto link
		{
			regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
			format = "mailto:$0",
		},
	},
}

-- === Domains ===
local domains = {
	-- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
	-- ssh_domains = {},
	ssh_domains = {
		-- yazi's image preview on Windows will only work if launched via ssh from WSL
		{
			name = "wsl.ssh",
			remote_address = "localhost",
			multiplexing = "None",
			default_prog = { "fish", "-l" },
			assume_shell = "Posix",
		},
	},

	-- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
	unix_domains = {},

	-- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
	wsl_domains = {
		{
			name = "WSL:Ubuntu-24.04",
			distribution = "Ubuntu-24.04",
			default_cwd = "/home/oomor",
			default_prog = { "/usr/bin/env", "zsh", "-l", "-c", "exec /usr/bin/env zsh" },
		},
	},
}

-- === launch ===
local launch = {
	default_prog = {},
	launch_menu = {},
}

if platform.is_win then
	launch.default_prog = { "/usr/bin/env", "zsh", "-l", "-c", "exec /usr/bin/env zsh" }
	launch.default_domain = "WSL:Ubuntu-24.04"
	launch.launch_menu = {}
elseif platform.is_mac then
	launch.default_prog = { "zsh", "-l" }
	launch.launch_menu = {
		{ label = "Zsh", args = { "zsh", "-l" } },
	}
elseif platform.is_linux then
	launch.default_prog = { "zsh", "-l" }
	launch.launch_menu = {
		{ label = "Zsh", args = { "zsh", "-l" } },
	}
end

-- === Bindings ===
local act = wezterm.action
local mod = {}
if platform.is_mac then
	mod.SUPER = "SUPER"
	mod.SUPER_REV = "SUPER|CTRL"
elseif platform.is_win or platform.is_linux then
	mod.SUPER = "ALT" -- to not conflict with Windows key shortcuts
	mod.SUPER_REV = "ALT|CTRL"
end

-- stylua: ignore
local leader = { key = "Space", mods = mod.SUPER }
local keys = {
   -- misc/useful --
   { key = 'v', mods = 'LEADER', action = act.ActivateCopyMode },
   { key = 'F1', mods = 'LEADER', action = act.ActivateCopyMode },
   { key = 'F2', mods = 'NONE', action = act.ActivateCommandPalette },
   { key = 'F3', mods = 'NONE', action = act.ShowLauncher },
   { key = 'F4', mods = 'NONE', action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS' }) },
   {
      key = 'F5',
      mods = 'NONE',
      action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }),
   },
   { key = 'F11', mods = 'NONE',    action = act.ToggleFullScreen },
   { key = 'F12', mods = 'NONE',    action = act.ShowDebugOverlay },
   { key = 'f',   mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = '' }) },
   {
      key = 'u',
      mods = mod.SUPER_REV,
      action = wezterm.action.QuickSelectArgs({
         label = 'open url',
         patterns = {
            '\\((https?://\\S+)\\)',
            '\\[(https?://\\S+)\\]',
            '\\{(https?://\\S+)\\}',
            '<(https?://\\S+)>',
            '\\bhttps?://\\S+[)/a-zA-Z0-9-]+'
         },
         action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            wezterm.log_info('opening: ' .. url)
            wezterm.open_with(url)
         end),
      }),
   },

   -- cursor movement --
   { key = 'LeftArrow',  mods = mod.SUPER,     action = act.SendString '\u{1b}OH' },
   { key = 'RightArrow', mods = mod.SUPER,     action = act.SendString '\u{1b}OF' },
   { key = 'Backspace',  mods = mod.SUPER,     action = act.SendString '\u{15}' },

   -- copy/paste --
   { key = 'c',          mods = 'CTRL|SHIFT',  action = act.CopyTo('Clipboard') },
   { key = 'v',          mods = 'CTRL|SHIFT',  action = act.PasteFrom('Clipboard') },

   -- tabs --
   -- tabs: spawn+close
   { key = 't',          mods = mod.SUPER,     action = act.SpawnTab('DefaultDomain') },
   { key = 't',          mods = mod.SUPER_REV, action = act.SpawnTab({ DomainName = 'WSL:Ubuntu' }) },
   { key = 'w',          mods = mod.SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) },
   {
      key = 'T',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(
        wezterm.action.PromptInputLine {
          description = 'Enter title for new tab:',
          action = wezterm.action_callback(function(window, pane, line)
            if line and line ~= "" then
              window:perform_action(wezterm.action.SpawnTab 'DefaultDomain', pane)
              
              local new_tab = window:active_tab()
              local new_pane = new_tab:active_pane()
              new_tab:set_title(line)
              new_pane:set_title(line)
            end
          end),
        },
        pane
      )
    end),
   },

   -- tabs: navigation
   { key = '[',          mods = mod.SUPER,     action = act.ActivateTabRelative(-1) },
   { key = ']',          mods = mod.SUPER,     action = act.ActivateTabRelative(1) },
   { key = '[',          mods = mod.SUPER_REV, action = act.MoveTabRelative(-1) },
   { key = ']',          mods = mod.SUPER_REV, action = act.MoveTabRelative(1) },

   -- tab: title
   { key = '0',          mods = mod.SUPER,     action = act.EmitEvent('tabs.manual-update-tab-title') },
   { key = '0',          mods = mod.SUPER_REV, action = act.EmitEvent('tabs.reset-tab-title') },

   -- tab: hide tab-bar
   { key = '9',          mods = mod.SUPER,     action = act.EmitEvent('tabs.toggle-tab-bar'), },

   -- window --
   -- window: spawn windows
   { key = 'n',          mods = mod.SUPER,     action = act.SpawnWindow },

   -- window: zoom window
   {
      key = '-',
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         local dimensions = window:get_dimensions()
         if dimensions.is_full_screen then
            return
         end
         local new_width = dimensions.pixel_width - 50
         local new_height = dimensions.pixel_height - 50
         window:set_inner_size(new_width, new_height)
      end)
   },
   {
      key = '=',
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         local dimensions = window:get_dimensions()
         if dimensions.is_full_screen then
            return
         end
         local new_width = dimensions.pixel_width + 50
         local new_height = dimensions.pixel_height + 50
         window:set_inner_size(new_width, new_height)
      end)
   },

   -- background controls --
   {
      key = [[/]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:random(window)
      end),
   },
   {
      key = [[,]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:cycle_back(window)
      end),
   },
   {
      key = [[.]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:cycle_forward(window)
      end),
   },
   {
      key = [[/]],
      mods = mod.SUPER_REV,
      action = act.InputSelector({
         title = 'InputSelector: Select Background',
         choices = backdrops:choices(),
         fuzzy = true,
         fuzzy_description = 'Select Background: ',
         action = wezterm.action_callback(function(window, _pane, idx)
            if not idx then
               return
            end
            ---@diagnostic disable-next-line: param-type-mismatch
            backdrops:set_img(window, tonumber(idx))
         end),
      }),
   },
   {
      key = 'b',
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:toggle_focus(window)
      end)
   },

   -- panes --
   -- panes: split panes
   {
      key = [[\]],
      mods = mod.SUPER,
      action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
   },
   {
      key = [[\]],
      mods = mod.SUPER_REV,
      action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
   },

   -- panes: zoom+close pane
   { key = 'Enter', mods = mod.SUPER,     action = act.TogglePaneZoomState },
   { key = 'w',     mods = mod.SUPER,     action = act.CloseCurrentPane({ confirm = false }) },

   -- panes: navigation
   { key = 'k',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Up') },
   { key = 'j',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Down') },
   { key = 'h',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Left') },
   { key = 'l',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Right') },
   {
      key = 'p',
      mods = mod.SUPER_REV,
      action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }),
   },

   -- panes: scroll pane
   { key = 'u',        mods = mod.SUPER, action = act.ScrollByLine(-5) },
   { key = 'd',        mods = mod.SUPER, action = act.ScrollByLine(5) },
   { key = 'PageUp',   mods = 'NONE',    action = act.ScrollByPage(-0.75) },
   { key = 'PageDown', mods = 'NONE',    action = act.ScrollByPage(0.75) },

   -- workspace --
   {
      key = 'm',
      mods = mod.SUPER,
      action = act.PromptInputLine {
         description = "(wezterm) Create new workspace:",
         action = wezterm.action_callback(workspace.create_workspace)
      }
   },
   {
      key = 'm',
      mods = 'CTRL|SHIFT',
      action = wezterm.action_callback(workspace.switch_workspace)
   },
   {
      key = 'n',
      mods = 'CTRL|SHIFT',
      action = act.SwitchWorkspaceRelative(1)
   },
   {
      key = 'p',
      mods = 'CTRL|SHIFT',
      action = act.SwitchWorkspaceRelative(-1)
   },
   
   -- key-tables --
   -- resizes fonts
   {
      key = 'f',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_font',
         one_shot = false,
         timemout_miliseconds = 1000,
      }),
   },
   -- resize panes
   {
      key = 'p',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_pane',
         one_shot = false,
         timemout_miliseconds = 1000,
      }),
   },
}

-- stylua: ignore
local key_tables = {
   resize_font = {
      { key = 'k',      action = act.IncreaseFontSize },
      { key = 'j',      action = act.DecreaseFontSize },
      { key = 'r',      action = act.ResetFontSize },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
   resize_pane = {
      { key = 'k',      action = act.AdjustPaneSize({ 'Up', 1 }) },
      { key = 'j',      action = act.AdjustPaneSize({ 'Down', 1 }) },
      { key = 'h',      action = act.AdjustPaneSize({ 'Left', 1 }) },
      { key = 'l',      action = act.AdjustPaneSize({ 'Right', 1 }) },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
}

local mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
}

local bindings = {
	disable_default_key_bindings = true,
	-- disable_default_mouse_bindings = true,
	leader = leader,
	keys = keys,
	key_tables = key_tables,
	mouse_bindings = mouse_bindings,
}

---@class ConfigBuilder
---@field options Config
local Config = {}
Config.__index = Config

---Initialize Config
---@return ConfigBuilder
function Config:init()
   local config = setmetatable({ options = {} }, self)
   return config
end

---Append to `Config.options`
---@param new_options table new options to append
---@return ConfigBuilder
function Config:append(new_options)
   for k, v in pairs(new_options) do
      if self.options[k] ~= nil then
         wezterm.log_warn(
            'Duplicate config option detected: ',
            { old = self.options[k], new = new_options[k] }
         )
         goto continue
      end
      self.options[k] = v
      ::continue::
   end
   return self
end

return Config:init()
   :append(appearance)
   :append(fonts)
   :append(general)
   :append(bindings)
   :append(domains)
   :append(launch).options
