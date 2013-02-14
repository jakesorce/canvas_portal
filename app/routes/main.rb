class Portal < Sinatra::Application
  get '/' do
    if File.exists? Files::GENERATING_FILE
      erb :generating
    else
      if Files.first_line("/var/run/apache2.pid") == nil
        erb :index
      else
        patchsets = Files.first_line(Files::MULTIPLE_FILE).split(',') rescue nil
        erb :server_status, :locals => { :branch => Files.branch_file, :plugin_info => Files.first_line(Files::PLUGIN_FILE), :patchset => Files.first_line(Files::PATCHSET_FILE), :patchsets => patchsets }
      end
    end
  end 
end
