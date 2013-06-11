require 'sinatra/base'
module Sinatra::DB
  def update_fields(fields = {})
    db = PortalData.first
    db.attributes = fields
    db.save!
    update_last_action_time if fields.include? :portal_action
  end

  def update_last_action_time
    PortalData.first.update_attributes(last_action_time: Time.now.in_time_zone('America/Denver').strftime("%m/%d/%Y at %I:%M%p"))
  end

  def update_action_time(action, time)
    fields = {action: action, time: time}
    db = ActionTimes.first
    db.attributes = fields
    db.save!
  end

  def update_flags(documentation, localization)
    update_fields({documentation: documentation, localization: localization})   
  end
end
