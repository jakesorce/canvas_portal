class Portal < Sinatra::Application
  post "/documentation" do
    Writer.write_info('generate documentation')
    system("ruby /home/hudson/canvas-lms/branch_tools.rb -g 'true'")
  end
end
