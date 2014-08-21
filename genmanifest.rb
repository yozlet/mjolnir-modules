name = "core.keycodes"
version = "0.1"

require 'json'
require 'digest'
md = {version: version,
      license: "MIT",
      minosx: "10.8",
      author: "Steven Degutis",
      website: "https://github.com/mjolnir-io/mjolnir.#{name}",
      tarfile: "https://github.com/mjolnir-io/mjolnir.#{name}/releases/download/#{version}/#{name}.tgz",
      sha: Digest::SHA1.hexdigest(File.read("#{name}.tgz")),
      description: "Functionality for converting between key-strings and key-codes.",
      deps: [],
      changelog: DATA.read.strip}

puts JSON.pretty_generate(md)

__END__

0.1: Initial release.
