ActiveRecord::Base.establish_connection(
    :adapter => 'mysql2',
    :host => 'localhost',
    :encoding => 'utf8',
    :database => 'canvas_portal',
    :username => 'root',
    :password => 'swordfish'
)

class ActionTimes < ActiveRecord::Base
  ActiveRecord::Migration.class_eval do
    unless table_exists? :action_times
      create_table :action_times do |t|
        t.string :action
        t.integer :time
      end
    end
  end
end
