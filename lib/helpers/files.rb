require 'active_support'

module Files
  ERROR_FILE = "#{Dirs::FILES}/error.txt"
  BTOOLS = "#{Dirs::CANVAS}/branch_tools.rb"
  
  def remove_error_file
    File.delete(ERROR_FILE) if File.exists? ERROR_FILE
  end

  def remove_file(file_path)
    File.delete(file_path) if File.exists? file_path
  end

  def first_line(file_path)
    File.open(file_path) { |file| file.gets } if File.exists? file_path
  end

  def branch_file
    PortalData.first.branch rescue Dir.chdir("#{Dirs::CANVAS}") { Git.current_branch }
  end
   
  def all_lines(file_path)
    File.open(file_path) { |file| file.readlines } if File.exists? file_path
  end
  module_function :first_line
  module_function :remove_error_file
  module_function :remove_file
  module_function :branch_file
  module_function :all_lines
end
