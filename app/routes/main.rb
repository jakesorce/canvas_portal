class Portal < Sinatra::Application
  get '/' do
    if File.exists? Files::GENERATING_FILE
      erb :generating
    else
      if Files.first_line("/var/run/apache2.pid") == nil
        if File.exists? Files::INFO_FILE
          info_lines = File.readlines(Files::INFO_FILE)
          dt_last_action = info_lines.first
          last_action = info_lines.last
        elsif File.exists? Files::ERROR_FILE
          dt_last_action = last_action = 'an error occurred on the last action, try again'
        else
          dt_last_action = last_action = 'no portal action has taken place'
        end
        erb :index
      else
        branch = Files.first_line(Files::BRANCH_FILE) rescue Git.current_branch
        patchsets = Files.first_line(Files::MULTIPLE_FILE).split(',') rescue nil
        erb :server_status, :locals => { :branch => branch, :plugin_info => Files.first_line(Files::PLUGIN_FILE), :patchset => Files.first_line(Files::PATCHSET_FILE), :patchsets => patchsets }
      end
    end
  end 
end
