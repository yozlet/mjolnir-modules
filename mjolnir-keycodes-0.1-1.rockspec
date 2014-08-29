package = "mjolnir-keycodes"
version = "0.1-1"
source = {
  url = "https://github.com/mjolnir-io/mjolnir-keycodes/archive/master.zip"
}
description = {
  summary = "Convert between key-strings and key-codes.",
  detailed = "Convert between key-strings and key-codes.",
  homepage = "https://github.com/mjolnir-io/mjolnir-keycodes",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1, < 5.3"
}
build = {
  type = "builtin",
  modules = {
    ["mj.keycodes"] = "keycodes.lua",
    ["mj.keycodes.internal"] = "keycodes-internal.m",
  }
}
