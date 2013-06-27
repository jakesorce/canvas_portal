class Portal < Sinatra::Application
  get "/action_time" do
    ActionTimes.create! if ActionTimes.first == nil
    action = ActionTimes.find_by_action(params.keys.first)
    ActiveRecord::Base.connection.close
    response.write(action.time.to_s) if action
  end
 
  get "/error_log" do
    response.write(`cat #{Dirs::HUDSON}/logs/sinatra_server_log.txt`)
  end

  get "/error_file_text" do
    response.write(`cat #{Files::ERROR_FILE}`)
  end

  post "/dcm_initial_data" do
    update_fields({portal_action: 'reset database'})
    Tools.btools_command(params)
  end
  
  post '/backup_db' do
    update_fields({portal_action: 'backup database'})
    Tools.btools_command(params)
  end

  post '/restore_db' do
    update_fields({portal_action: 'restore database'})
    Tools.btools_command(params)
  end

  post "/apache_server/:action" do |action|
    update_fields({portal_action: 'start server'}) if action == 'start'
    Tools.apache_server(action)
  end
 
  post '/shutdown' do
    update_fields({portal_action: 'shut down portal'})
    Tools.shut_down_portal
  end

  post '/restart_jobs_canvas' do
    update_fields({portal_action: 'restart jobs canvas'})
    Tools.restart_jobs("#{Dirs::CANVAS}")
    Tools.apache_server('start')
  end

  post '/restart_jobs_canvasnet' do
    update_fields({portal_action: 'restart jobs canvasnet'})
    Tools.restart_jobs("#{Dirs::UDEMODO}", true)
    Tools.apache_server('start')
  end
end
