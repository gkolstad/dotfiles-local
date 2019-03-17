utilMenu = hs.menubar.new()

local icon = [[
1 . . . . . . . . . . . 3
. # # . . . . . . . # # .
. # # # # . . . # # # # .
. . # # # # 2 # # # # . .
. . # # # # # # # # # . .
. . . # # # # # # # . . .
. . . 8 # # # # # 4 . . .
. . . # # # # # # # . . .
. . # # # # # # # # # . .
. . # # # # 6 # # # # . .
. # # # # . . . # # # # .
. # # . . . . . . . # # .
7 . . . . . . . . . . . 5
]]

utilMenu:setIcon('ASCII:' .. icon)

local menu = nil

local reloadMenu = function() utilMenu:setMenu(menu) end

menu = {
  {
    title = "Mono audio",
    checked = false,
    fn = function(modifiers, menuItem)
      local script = [[
        tell application "System Preferences"
          reveal anchor "Hearing" of pane id "com.apple.preference.universalaccess"
        end tell

        tell application "System Events"
          tell application process "System Preferences"
            set frontmost to true
            tell group 1 of window "Accessibility"
              activate
              repeat until checkbox "Play stereo audio as mono" exists
                delay 0.05
              end repeat
              set monoStereoCheckbox to checkbox "Play stereo audio as mono"
              tell monoStereoCheckbox
                if (%s its value as boolean) then click monoStereoCheckbox
              end tell
            end tell
          end tell
        end tell

        tell application "System Preferences" to quit
      ]]

      local toggle = ""
      if not menuItem.checked then
        toggle = "not"
      end
      script = string.format(script, toggle)
      hs.osascript.applescript(script)

      menuItem.checked = not menuItem.checked
      reloadMenu()
    end
  },
  {
    title = "Caffeinate",
    checked = false,
    fn = function(modifiers, menuItem)
      local enabled = hs.caffeinate.toggle('displayIdle')
      if enabled then
        hs.notify.new({title='Caffeinate', informativeText='Caffeinate on'}):send()
      else
        hs.notify.new({title='Caffeinate', informativeText='Caffeinate off'}):send()
      end

      menuItem.checked = enabled
      reloadMenu()
    end
  },
  {
    title = "-" -- separator
  },
  {
    title = "Rescue windows",
    fn = rescue
  },
  {
    title = "-" -- separator
  },
  {
    title = "Layout: Dorm Terminal",
    fn = function()
      applyLayout("Dorm Terminal", layoutDormTerminal)
    end
  },
  {
    title = "Layout: Dorm Terminal Focus",
    fn = function()
      applyLayout("Dorm Terminal Focus", layoutDormTerminalFocus)
    end
  },
  {
    title = "Layout: Lab",
    fn = function()
      -- choose layout based on whether Emacs is running
      if hs.application.get('Emacs') then
        applyLayout("Lab (Emacs)", layoutLabEmacs)
      else
        applyLayout("Lab (Terminal)", layoutLabTerminal)
      end
    end
  },
  {
    title = "Layout: Lab Focus",
    fn = function()
      -- choose layout based on whether Emacs is running
      if hs.application.get('Emacs') then
        applyLayout("Lab Focus (Emacs)", layoutLabEmacsFocus)
      else
        applyLayout("Lab Focus (Terminal)", layoutLabTerminalFocus)
      end
    end
  },
  {
    title = "Layout: Home",
    fn = function()
      applyLayout("Home", layoutHome)
    end
  },
  {
    title = "Layout: Laptop",
    fn = function()
      applyLayout("Laptop", layoutLaptop)
    end
  },
}

reloadMenu()
