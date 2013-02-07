class Portal < Sinatra::Application
  post "/localization" do
    Writer.write_info('localization validation')
    system("ruby /home/hudson/canvas-lms/branch_tools.rb -l 'localize'")
  end 
end 
