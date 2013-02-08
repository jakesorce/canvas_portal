class Portal < Sinatra::Application
  get "/branch_list" do
    Dir.chdir("#{Dirs::CANVAS}") { response.write(Git.all_branches) }
  end

  post "/branch" do
    Writer.write_info('branch checkout')
    branch = params.values.first
    Writer.write_file(Files::BRANCH_FILE, branch)
    Tools.btools_command(params)
  end
end
