class Portal < Sinatra::Application
  get "/ruby_version" do
    response.write(Version.global)
  end

  post "/change_version" do
    Writer.write_info('change ruby version')
    version = params.values.first
    Version.change_version(version)
  end
end

