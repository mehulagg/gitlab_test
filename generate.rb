raise "Usage #{__FILE__} input_file output file" unless ARGV.size == 2

input_file = ARGV[0]
output_file = ARGV[1]

# input_file = './all_require_uniq.txt'
# output_file = './generated_single_require_file.rb'

def ruby_file?(file_path)
  File.extname(file_path) == '.rb'
end

def bundle_file?(file_path)
  File.extname(file_path) == '.bundle'
end

def can_append_file_content?(file_path)
  ruby_file?(file_path)
end

def append_string_to_file(str_to_append, target_file)
  File.open(target_file, "a") do |target|
    target.puts(str_to_append)
  end
end

def append_extra_info(file_path, target_file)
  to_append = "last_required_file_path = '#{file_path}'"

  append_string_to_file(to_append, target_file)

  #avoid duplicate require later
  to_append = "$\" << '#{file_path}'"

  append_string_to_file(to_append, target_file)
end

def append_file_content(file_path, target_file)
  throw "not supported: #{file_path}" unless can_append_file_content?(file_path)

  to_append = File.read(file_path)

  append_string_to_file(to_append, target_file)
end

def append_require_file_statement(file_path, target_file)
  to_append = "require '#{file_path}'"

  append_string_to_file(to_append, target_file)
end

def delete_file(file_path)
  File.unlink(file_path) if File.exist?(file_path)
end

# start work

delete_file(output_file)

all_files = File.readlines(input_file)

all_files.each do |file_path|
  p file_path

  file_path.strip!
  p file_path

  if ruby_file?(file_path)
    append_extra_info(file_path, output_file)
    append_file_content(file_path, output_file)
  elsif bundle_file?(file_path)
    append_require_file_statement(file_path, output_file)
  else
    throw "Neither ruby nor bundle file: #{file_path}"
  end
end
