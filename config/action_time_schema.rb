CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'action_times_config.yml'))
ActiveRecord::Base.establish_connection(
    :adapter => 'mysql2',
    :host => 'localhost',
    :encoding => 'utf8',
    :database => CONFIG['database'],
    :username => CONFIG['database-user'],
    :password => CONFIG['user-password']
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
