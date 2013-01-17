class Portal < Sinatra::Application
  get "/branch_list" do
    Dir.chdir('/home/hudson/canvas-lms') { response.write(`git branch -r`) }
  end

  post "/branch" do
    Files.remove_files
    execution_time = Benchmark.realtime do
      Writer.write_info('branch checkout')
      branch = params.keys[0]
      Writer.write_file(BRANCH_FILE, branch)
      system("ruby /home/hudson/canvas-lms/branch_tools.rb -b '#{branch}'")
    end
  ActionTime.store_action_time('branch', execution_time) if Validation.check_error_file
  end
end
