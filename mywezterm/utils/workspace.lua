local wezterm = require('wezterm')
local act = wezterm.action
local M = {}

M.create_workspace = function(window, pane, line)
   if line then
      window:perform_action(
         act.SwitchToWorkspace({
            name = line,
         }),
         pane
      )
   end
end

M.switch_workspace = function(win, pane)
   local workspaces = {}
   for i, name in ipairs(wezterm.mux.get_workspace_names()) do
      table.insert(workspaces, {
         id = name,
         label = string.format('%d. %s', i, name),
      })
   end
   local current = wezterm.mux.get_active_workspace()
   win:perform_action(
      act.InputSelector({
         action = wezterm.action_callback(function(_, _, id, label)
            if not id and not label then
               wezterm.log_info('Workspace selection canceled')
            else
               win:perform_action(act.SwitchToWorkspace({ name = id }), pane)
            end
         end),
         title = 'Select workspace',
         choices = workspaces,
         fuzzy = true,
         -- fuzzy_description = string.format("Select workspace: %s -> ", current), -- requires nightly build
      }),
      pane
   )
end

return M
