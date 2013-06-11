require 'pry'

module Validation
  def check_error_file
    portal_user = PORTAL_CONFIG['portal']['username']
    if File.exists? Files::ERROR_FILE
      Connection.manage_connection do
        PortalData.first.update_attributes({portal_action: nil})
      end
      mail = Mail.deliver do
        to PORTAL_CONFIG['sendgrid']['emails']
        from "Portal V4  #{portal_user} <portalv4#{portal_user}@instructure.com>"
        subject "Portal Error #{portal_user}"
        html_part do
          body File.read("#{Dirs::SINATRA_LOGS}/sinatra_server_log.txt")
        end
      end
      return false
    else
      return true
    end
  end
  
  def is_patchset(value)
    /^\d+\/\d+\/\d+$/.match(value) == nil ? false : true
  end
 
  def validate_patchset(input)
    if is_patchset(input)
      return true
    else
      Writer.write_file(Files::ERROR_FILE, 'patchset validation failed')
      return false
    end
  end

  def is_plugin(value)
     /^git\s(fetch|pull)\sssh:\/\/[a-zA-Z]*@gerrit.instructure.com:29418\/\S*\srefs\/changes\/\d+\/\d+\/\d+/.match(value) == nil ? false : true
  end
  
  def validate_plugin(input)
    if is_plugin(input)
      return true
    else
      Writer.write_file(Files::ERROR_FILE, 'plugin validatoin failed')
      return false
    end
  end

  def validate_gerrit_url(input)
    if input !~ /^git\s(fetch|pull)\sssh:\/\/[a-zA-Z]*@gerrit.instructure.com:29418\/\S*\srefs\/changes\/\d+\/\d+\/\d+/ 
      Writer.write_file(Files::ERROR_FILE, 'url validation failed')
      false
    else
      true
    end
  end
  module_function :is_patchset
  module_function :check_error_file
  module_function :validate_patchset
  module_function :validate_gerrit_url
  module_function :validate_plugin
  module_function :is_plugin
end
