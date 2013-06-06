class Portal < Sinatra::Application
  post "/localization" do
    update_fields({portal_action: 'localization validation', localization: true})
    Tools.btools_command(params)
  end 
end 
