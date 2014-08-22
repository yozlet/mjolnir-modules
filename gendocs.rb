require 'json'
require 'pp'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

comments = []
ARGV.each do |file|
  partialcomment = []
  islua = file.end_with?(".lua")
  comment = islua ? "-" : "/"
  incomment = false
  File.read(file).split("\n").each do |line|
    if line.start_with?(comment*3) and !line.start_with?(comment*4) then
      incomment = true
      partialcomment << line[3..-1].sub(/^\s/, '')
    elsif incomment then
      incomment = false
      comments << partialcomment
      partialcomment = []
    end
  end
  unless partialcomment.empty?
    abort "Comment found at end of file (presumably):\n #{partialcomment.pretty_inspect}"
  end
end

newmod  = ->(c) {{name: c[0].gsub('=', '').strip,
                  doc: c[1..-1].join("\n").strip,
                  items: []}}

newitem = ->(c) {{type: "Function", # TODO: figure out what the type
                                    # really is (it's not always a
                                    # function); probably requires a
                                    # stricter docs format
                  name: nil,
                  def: c[0],
                  doc: c[1..-1].join("\n").strip}}

ismod = ->(c) { c[0].include?('===') }
mods  = comments.select(&ismod).map(&newmod)
items = comments.reject(&ismod).map(&newitem)
orderedmods = mods.sort_by{|m|m[:name]}.reverse

items.each do |item|
  mod = orderedmods.find{|mod| item[:def].start_with?(mod[:name])}
  if mod.nil?
    abort "error: couldn't find module for #{item[:def]}"
  end
  item[:name] = item[:def][(mod[:name].size+1)..-1].match(/\w+/)[0]
  mod[:items] << item
end

mods.sort_by!{|m|m[:name]}
puts JSON.pretty_generate(mods)
