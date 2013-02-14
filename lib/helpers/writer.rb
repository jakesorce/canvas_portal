module Writer
  def write_file(file_path, contents, write_flag = 'w+')
    File.open(file_path, write_flag) { |file| file.write(contents) }
  end

  def write_info(action)
    Time.zone = ActiveSupport::TimeZone[-7].name
    write_file(Files::INFO_FILE, "#{Time.zone.now.strftime("%m/%d/%Y at %I:%M%p")}\n#{action}")
  end
  module_function :write_file
  module_function :write_info
end
