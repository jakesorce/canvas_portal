module ActionTime
  def store_action_time(action, execution_time)
    require '/home/hudson/portal/config/action_time_schema' 
    ActionTimes.find_or_create_by_action(action).update_attributes({:time => (execution_time.round * 1000)})
    ActiveRecord::Base.connection.close
  end 
  module_function :store_action_time
end

module Writer
  def write_response(file)
    response.write(File.open(file).gets)
  end
  
  def write_file(file_path, contents)
    File.open(file_path, "w") { |file| file.write(contents) }
  end

  def write_info(action)
    Time.zone = ActiveSupport::TimeZone[-7].name
    write_file(INFO_FILE, "#{Time.zone.now.strftime("%m/%d/%Y at %I:%M%p")}\n#{action}")
  end
  module_function :write_response
  module_function :write_file
  module_function :write_info 
end

module Files
  def remove_files(files = [BRANCH_FILE, PATCHSET_FILE, PLUGIN_FILE, MULTIPLE_FILE])
    files.each { |file| File.delete(file) if File.exists? file }
  end
  module_function :remove_files
end

module Validation
  def check_error_file
    File.delete(GENERATION_FILE) if File.exists? GENERATION_FILE
    if File.exists? ERROR_FILE
      Writer.write_response(ERROR_FILE)
      File.delete(INFO_FILE)
      mail = Mail.deliver do
        to EMAIL['emails']
        from 'Portal V4 [NAME] <portalv4[name]@instructure.com>'
        subject 'Portal Error [Name]'
        html_part do
          body File.read('/home/hudson/logs/sinatra_server_log.txt')
        end
      end
      return false
    else
      return true
    end
  end
  module_function :check_error_file
end
