class Portal < Sinatra::Application
  post "/documentation" do
    update_fields({portal_action: 'generate documentation', documentation: true})
    Tools.btools_command(params)
  end
end
