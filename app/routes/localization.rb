class Portal < Sinatra::Application
  post "/localization" do
    Writer.write_info('localization validation')
    Writer.write_file(Files::LOCALIZATION_FILE, 'localize')
    Tools.btools_command(params)
  end 
end 
