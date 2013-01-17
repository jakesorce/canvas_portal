class Portal < Sinatra::Application
  post "/localization" do
    execution_time = Benchmark.realtime do
      Writer.write_info('localization validation')
      system("ruby /home/hudson/canvas-lms/branch_tools.rb -l 'localize'")
    end
    ActionTime.store_action_time('localization', execution_time) if Validation.check_error_file
  end 
end 
