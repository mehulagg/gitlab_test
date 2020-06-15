raise "Usage: #{__FILE__} input_file output_file" unless ARGV.size == 2
input_file = ARGV[0]
output_file = ARGV[1]

# input_file = './generated_single_require_file.rb'
# output_file = './generated_single_require_file_no_require_relative.rb'

puts input_file

def append_string_to_file(str_to_append, target_file)
  File.open(target_file, "a") do |target|
    target.puts(str_to_append)
  end
end

def relative_to_require(line, last_required_file_dir)
  raise 'last_required_file_dir empty!' unless last_required_file_dir

  require_relative_file_name = nil

  require_relative_match = /^([ ]*)require_relative ['"](.*)['"]$/.match(line)

  return line unless require_relative_match

  spaces = require_relative_match[1]
  require_relative_file_name = require_relative_match[2]

  absolute_file_path = File.join(last_required_file_dir, require_relative_file_name)

  "#{spaces}require '#{absolute_file_path}'"
end

# TEST:
# puts relative_to_require("                require_relative 'abc'", '/root/dir')
# exit
# return
# End of TEST

File.unlink(output_file) if File.exist?(output_file)

last_required_file_dir = nil

File.open(input_file, "r") do |input_file|
  input_file.each_line do |line|
    last_required_file_match = /^last_required_file_path = '(.*)'$/.match(line)
    if last_required_file_match
      last_required_file_dir = File.dirname(last_required_file_match[1])
    end

    line_to_append = relative_to_require(line, last_required_file_dir)
    append_string_to_file(line_to_append, output_file)
  end
end

puts <<NOTES
  NOTE: this currently only handles:
   - the whole line is: ` require_relative 'file'`
   - the whole line is: `require_relative "file"`

  These have covered the majority of the `require_relative` in the generated file.
  But there are some cases not handled:
   - require_relative('file')
   - require_relative 'file' if condition

  So please open the output file and manually handle these cases. There are not many. We do not bother to do it automatically as of now.
  To find the dirname, search back for `last_required_file_path` -- that value is the original file path which contains the `require_relative` statement

NOTES
