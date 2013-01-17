class Portal < Sinatra::Application
  post "/documentation" do
    execution_time = Benchmark.realtime do
      Writer.write_info('generate documentation')
      system("ruby /home/hudson/canvas-lms/branch_tools.rb -g 'true'")
    end
    ActionTime.store_action_time('documentation', execution_time) if Validation.check_error_file
  end
end
