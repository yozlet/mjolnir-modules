package = "mjolnir-hotkey"
version = "0.1-1"
local url = "github.com/mjolnir-io/mjolnir-core"
local desc = "Mjolnir module to create and manage global hotkeys."
source = {url = "git://" .. url}
description = {
  summary = desc,
  detailed = desc,
  homepage = "https://" .. url,
  license = "MIT",
}
supported_platforms = {"macosx"}
dependencies = {
  "lua >= 5.2",
  "mj.keycodes",
}
build = {
  type = "builtin",
  modules = {
    ["mj.hotkey"] = "hotkey.lua",
    ["mj.hotkey.internal"] = "hotkey-internal.m",
  },
}