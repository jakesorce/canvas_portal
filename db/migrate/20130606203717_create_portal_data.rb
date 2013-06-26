class CreatePortalData < ActiveRecord::Migration
  def self.up
    unless table_exists? :portal_data
      create_table :portal_data do |t|
        t.string :branch
	t.string :patchset
	t.string :plugin
	t.string :multiple
	t.string :portal_action
	t.string :last_action_time
	t.string :stage
	t.boolean :old_branch
	t.boolean :localization
	t.boolean :documentation
	t.boolean :generating
    end
  end

    unless table_exists? :action_times
      create_table :action_times do |t|
        t.string :action
        t.integer :time
      end 
    end
  end

  def self.down
    drop_table :portal_data if table_exists? :portal_data
    drop_table :action_times if table_exists? :action_times
  end
end
