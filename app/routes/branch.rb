class Portal < Sinatra::Application
  get "/branch_list" do
    Dir.chdir("#{Dirs::CANVAS}") { response.write(Git.all_branches) }
  end

  post "/branch" do
    Writer.write_info('branch checkout')
    Writer.write_file(Files::BRANCH_FILE, params.values.first)  
    Tools.btools_command(params)
  end
end
