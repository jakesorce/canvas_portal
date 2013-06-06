require 'sinatra/base'

module Sinatra::ActionTime
  def store_action_time(action, execution_time)
    time = (execution_time.round * 1000)
    ActionTimes.find_by_action(action) == nil ? ActionTimes.create!(action: action, time: time) : update_action_time(action, time)
    ActiveRecord::Base.connection.close
  end
  module_function :store_action_time
end
