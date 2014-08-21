--- === core.keycodes ===
--- Functionality for converting between key-strings and key-codes.

local keycodes = require "ext.core.keycodes.internal"
keycodes.map = keycodes.cachemap()

--- core.keycodes.inputsourcechanged()
--- Called when your input source (i.e. qwerty, dvorak, colemac) changes.
--- Default implementation does nothing; you may override this to rebind your hotkeys or whatever.
function keycodes.inputsourcechanged()
end

function keycodes._inputsourcechanged()
  keycodes.map = keycodes.cachemap()
  keycodes.inputsourcechanged()
end

return keycodes
