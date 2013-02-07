CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'action_times_config.yml'))
ActiveRecord::Base.establish_connection(
    :adapter => CONFIG['action-times']['adapter'],
    :host => CONFIG['action-times']['host'],
    :encoding => CONFIG['action-times']['encoding'],
    :database => CONFIG['action-times']['database'],
    :username => CONFIG['action-times']['username'],
    :password => CONFIG['action-times']['password']
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
