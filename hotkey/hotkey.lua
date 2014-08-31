--- === mj.hotkey ===
---
--- Create and manage global hotkeys.

local hotkey = require "mj.hotkey.internal"

--- mj.hotkey.bind(mods, key, pressedfn, releasedfn) -> hotkey
--- Shortcut for: return mj.hotkey.new(mods, key, pressedfn, releasedfn):enable()
function hotkey.bind(...)
  return hotkey.new(...):enable()
end

return hotkey
