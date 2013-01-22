class Portal < Sinatra::Application
  get '/' do
    if File.exists? GENERATION_FILE
      erb :generating
    else
      apache_pid_file = "/var/run/apache2.pid"
      pid = File.open(apache_pid_file) { |file| file.gets } if File.exist?(apache_pid_file)
      if pid == nil
        if File.exists? INFO_FILE
          info_lines = File.readlines(INFO_FILE)
          dt_last_action = info_lines.first
          last_action = info_lines.last
        elsif File.exists? ERROR_FILE
          dt_last_action = last_action = 'an error occurred on the last action, try again'
        else
          dt_last_action = last_action = 'no portal action has taken place'
        end
        erb :index
      else
        plugin_info = File.open(PLUGIN_FILE) { |file| file.gets } if File.exists? PLUGIN_FILE
        patchset = File.open(PATCHSET_FILE) { |file| file.gets } if File.exists? PATCHSET_FILE
        patchsets = File.open(MULTIPLE_FILE) { |file| file.gets }.split(',') if File.exists? MULTIPLE_FILE
        branch = File.readlines(BRANCH_FILE).first rescue Dir.chdir('/home/hudson/canvas-lms') { `git rev-parse --abbrev-ref HEAD` }
        erb :server_status, :locals => {:branch => branch, :plugin_info => plugin_info, :patchset => patchset, :patchsets => patchsets}
      end
    end
  end 
end
