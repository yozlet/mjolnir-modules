require 'json'
require 'digest'

name = "core.keycodes"

e = {}
e[:description] = "Convert between key-strings and key-codes."
e[:version]     = "0.1"
e[:license]     = "MIT"
e[:minosx]      = "10.8"
e[:author]      = "Steven Degutis"
e[:website]     = "https://github.com/mjolnir-io/mjolnir.#{name}"
e[:tarfile]     = "#{e[:website]}/releases/download/#{e[:version]}/#{name}.tgz"
e[:sha]         = Digest::SHA1.hexdigest(File.read("#{name}.tgz"))
e[:deps]        = []
e[:changelog]   = <<-EOCL
0.1: Initial release.
EOCL

puts JSON.pretty_generate(e)
