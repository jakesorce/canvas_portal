class Portal < Sinatra::Application
  get "/branch_list" do
    Dir.chdir("#{Dirs::CANVAS}") { response.write(Git.all_branches) }
  end

  post "/branch" do
    update_fields({portal_action: 'branch checkout', branch: params.values.first})
    update_flags(params[:docs], params[:localization])
    Tools.btools_command(params)
  end
end
