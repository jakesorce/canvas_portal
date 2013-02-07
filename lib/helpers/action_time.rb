module ActionTime
  def store_action_time(action, execution_time)
    require "#{Dirs::CONFIG}/action_time_schema"
    ActionTimes.find_or_create_by_action(action).update_attributes({:time => (execution_time.round * 1000)})
    ActiveRecord::Base.connection.close
  end
  module_function :store_action_time
end
