class Portal < Sinatra::Application
  get '/' do
    if File.exists? Files::GENERATING_FILE
      haml :generating
    else
      if Files.first_line("/var/run/apache2.pid") == nil
        haml :index
      else
        patchsets = Files.first_line(Files::MULTIPLE_FILE).split('*') rescue nil
        haml :server_status, :locals => { :branch => Files.branch_file, :plugin_info => Files.first_line(Files::PLUGIN_FILE), :patchset => Files.first_line(Files::PATCHSET_FILE), :patchsets => patchsets }
      end
    end
  end 
end
