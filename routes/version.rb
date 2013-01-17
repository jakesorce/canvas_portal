class Portal < Sinatra::Application
  get "/ruby_version" do
    response.write(`rbenv global`)
  end

  post "/change_version" do
    execution_time = Benchmark.realtime do
      Writer.write_info('change ruby version')
      version = params.keys[0]
      system("rbenv global #{version} && rbenv rehash")
      system("bash -lc 'rbenv shell #{version} && rbenv rehash && ruby /home/hudson/canvas-lms/branch_tools.rb -v #{version}'")
    end
    ActionTime.store_action_time('change_version', execution_time) if Validation.check_error_file
  end
end

