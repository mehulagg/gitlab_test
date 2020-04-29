require 'erb'
template = ERB.new(File.read(File.join(__dir__, 'shards_template.sql')))

Dir.glob(File.join(__dir__, "shard?.sql")).each { |f| File.delete(f) }

(0..7).each do |part_no|
  shard = "shard#{(part_no % 2)+1}"
  part = "issues_#{part_no}"

  File.open(File.join(__dir__, "#{shard}.sql"), "a+") do |io|
    io << template.result(binding)
  end
end