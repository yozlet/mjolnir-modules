package = "mjolnir-keycodes"
version = "0.1-1"
source = {
  url = "https://github.com/mjolnir-io/mjolnir-keycodes/archive/master.zip",
  dir = "mjolnir-keycodes-master",
}
description = {
  summary = "Convert between key-strings and key-codes.",
  detailed = "Convert between key-strings and key-codes.",
  homepage = "https://github.com/mjolnir-io/mjolnir-keycodes",
  license = "MIT",
}
supported_platforms = {"macosx"}
dependencies = {
  "lua >= 5.1, < 5.3",
}
build = {
  type = "command",
  build_command = "make all",
  install_command = "PREFIX=$(PREFIX) LUADIR=$(LUADIR) LIBDIR=$(LIBDIR) make install",
}
