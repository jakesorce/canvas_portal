module Files
  BRANCH_FILE = "#{Dirs::FILES}/branch.txt"
  PATCHSET_FILE = "#{Dirs::FILES}/patchset.txt"
  ERROR_FILE = "#{Dirs::FILES}/error.txt"
  PLUGIN_FILE = "#{Dirs::FILES}/plugin.txt"
  INFO_FILE = "#{Dirs::FILES}/portal_info.txt"
  MULTIPLE_FILE = "#{Dirs::FILES}/multiple.txt"
  GENERATING_FILE = "#{Dirs::FILES}/generating.txt"
  OLD_BRANCH_FILE = "#{Dirs::FILES}/old_branch.txt"
  LOCALIZATION_FILE = "#{Dirs::FILES}/localization.txt"
  DOCUMENTATION_FILE = "#{Dirs::FILES}/documentation.txt"
  BTOOLS = "#{Dirs::CANVAS}/branch_tools.rb"
  
  def remove_files(files = [BRANCH_FILE, PATCHSET_FILE, PLUGIN_FILE, MULTIPLE_FILE, LOCALIZATION_FILE, DOCUMENTATION_FILE, ERROR_FILE])
    files.each { |file| File.delete(file) if File.exists? file }
  end

  def remove_file(file_path)
    File.delete(file_path) if File.exists? file_path
  end

  def first_line(file_path)
    File.open(file_path) { |file| file.gets } if File.exists? file_path
  end

  def branch_file
    File.open(BRANCH_FILE) { |file| file.gets } rescue Dir.chdir("#{Dirs::CANVAS}") { Git.current_branch }
  end
   
  def all_lines(file_path)
    File.open(file_path) { |file| file.readlines } if File.exists? file_path
  end
  module_function :first_line
  module_function :remove_files
  module_function :remove_file
  module_function :branch_file
  module_function :all_lines
end
