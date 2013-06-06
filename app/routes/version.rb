class Portal < Sinatra::Application
  get "/ruby_version" do
    response.write(Version.global)
  end

  post "/change_version" do
    update_fields({portal_action: 'change ruby version'})
    Version.change_version(params)
  end
end

