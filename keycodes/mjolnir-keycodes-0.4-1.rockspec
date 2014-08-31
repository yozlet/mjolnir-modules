package = "mjolnir-keycodes"
version = "0.4-1"
local u = "git://github.com/mjolnir-io/mjolnir-core"
local d = "Mjolnir module to convert between key-strings and key-codes."
source = {url = u}
description = {
  summary = d,
  detailed = d,
  homepage = u,
  license = "MIT",
}
supported_platforms = {"macosx"}
dependencies = {
  "lua >= 5.2",
}
build = {
  type = "builtin",
  modules = {
    ["mj.keycodes"] = "keycodes.lua",
    ["mj.keycodes.internal"] = "keycodes-internal.m",
  },
}
