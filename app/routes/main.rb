class Portal < Sinatra::Application
  get '/' do
    PortalData.create! if PortalData.first == nil
    ActionTimes.create! if ActionTimes.first == nil
    pd = PortalData.first
    if pd.generating
      haml :generating
    else
      if Files.first_line("/var/run/apache2.pid") == nil
        haml :index
      else
        patchsets = pd.multiple.split('*') rescue nil
        haml :server_status, :locals => { :branch => pd.branch, :plugin_info => pd.plugin, :patchset => pd.patchset, :patchsets => patchsets }
      end
    end
  end 
end
