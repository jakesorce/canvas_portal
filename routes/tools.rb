class Portal < Sinatra::Application
  get "/action_time" do
    require '/home/hudson/portal/config/action_time_schema'
    action = ActionTimes.find_by_action(params.keys[0])
    ActiveRecord::Base.connection.close
    time = 0
    time = action.time if action != nil
    response.write(time)
    status 200
  end
 
  get "/error_log" do
    response.write(`cat /home/hudson/logs/sinatra_server_log.txt`)
  end

  post "/dcm_initial_data/:environment" do |environment|
    execution_time = Benchmark.realtime do
      Writer.write_info('reset database')
      system("ruby /home/hudson/canvas-lms/branch_tools.rb -d '#{environment}'")
    end
    ActionTime.store_action_time('dcm_initial_data', execution_time) if Validation.check_error_file
  end

  post "/apache_server/:action" do |action|
    execution_time = Benchmark.realtime do
      Writer.write_info('start server') if action == 'start'
      system("sudo service apache2 #{action}")
    end
    ActionTime.store_action_time('start_server', execution_time) if Validation.check_error_file
  end
 
  post '/shutdown' do
    execution_time = Benchmark.realtime do
      Writer.write_info('shut down portal')
      system("sudo shutdown -h now")
    end
    ActionTime.store_action_time('shutdown', execution_time)
  end
end
