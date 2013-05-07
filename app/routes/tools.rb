class Portal < Sinatra::Application
  get "/action_time" do
    require "#{Dirs::CONFIG}/action_time_schema"
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
    Writer.write_info('reset database')
    Tools.btools_command(params)
  end

  post "/apache_server/:action" do |action|
    Writer.write_info('start server') if action == 'start'
    Tools.apache_server(action)
  end
 
  post '/shutdown' do
    Writer.write_info('shut down portal')
    Tools.shut_down_portal
  end

  post '/restart_jobs_canvas' do
    Writer.write_info('restart jobs canvas')
    Tools.restart_jobs("#{Dirs::CANVAS}")
    Tools.apache_server('start')
  end

  post '/restart_jobs_canvasnet' do
    Writer.write_info('restart jobs canvasnet')
    Tools.restart_jobs("#{Dirs::UDEMODO}", true)
    Tools.apache_server('start')
  end
end
