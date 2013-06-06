module Writer
  def write_file(file_path, contents, write_flag = 'w+')
    File.open(file_path, write_flag) { |file| file.write(contents) }
  end
  module_function :write_file
end
