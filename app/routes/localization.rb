class Portal < Sinatra::Application
  post "/localization" do
    Writer.write_info('localization validation')
    Tools.btools_command(params)
  end 
end 
