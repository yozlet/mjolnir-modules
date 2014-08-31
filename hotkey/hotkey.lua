--- === mj.hotkey ===
---
--- Create and manage global hotkeys.

local hotkey = require "mj.hotkey.internal"

--- mj.hotkey.new(mods, key, pressedfn, releasedfn = nil) -> hotkey
--- Creates a new hotkey that can be enabled.
---
--- The `mods` parameter is case-insensitive and may contain any of the following strings: "cmd", "ctrl", "alt", or "shift".
---
--- The `key` parameter is case-insensitive and may be any string value found in mj.keycodes.map
---
--- The `pressedfn` parameter is the function that will be called when this hotkey is pressed.
---
--- The `releasedfn` parameter is the function that will be called when this hotkey is released; this field is optional (i.e. may be nil or omitted).


function hotkey.new(mods, key, pressedfn, releasedfn)
  local keycodes = require "mj.keycodes"
  local keycode = keycodes.map[key]

  local function _pressedfn()
    local ok, err = xpcall(pressedfn, debug.traceback)
    if not ok then mj.showerror(err) end
  end

  local function _releasedfn()
    local ok, err = xpcall(releasedfn, debug.traceback)
    if not ok then mj.showerror(err) end
  end

  local k = hotkey._new(mods, keycode, _pressedfn, _releasedfn)
  return k
end

--- mj.hotkey.bind(mods, key, pressedfn, releasedfn) -> hotkey
--- Shortcut for: return mj.hotkey.new(mods, key, pressedfn, releasedfn):enable()
function hotkey.bind(...)
  return hotkey.new(...):enable()
end

return hotkey
