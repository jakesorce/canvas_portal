class PortalData < ActiveRecord::Base
  attr_accessible :branch, :patchset, :plugin, :multiple, :old_branch, :portal_action, :last_action_time, :localization, :documentation, :generating
end
