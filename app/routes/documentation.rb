class Portal < Sinatra::Application
  post "/documentation" do
    Writer.write_info('generate documentation')
    Tools.btools_command(params)
  end
end
