require File.expand_path(File.join(File.dirname(__FILE__), "..", "init"))

Content.all.each do |c|
  c.save
end
MongoMapper.ensure_indexes!

puts "LOOKING!!!"
c = Content.all(:title_words => ['bol', 'hello'], :ctype => 'text')

puts c.to_yaml
