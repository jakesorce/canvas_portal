module Validation
  def check_error_file
    if File.exists? Files::ERROR_FILE
      File.delete(Files::INFO_FILE) if File.exists? Files::INFO_FILE
      mail = Mail.deliver do
        to EMAIL['sendgrid']['emails']
        from 'Portal V4 <portalv4@instructure.com>'
        subject 'Portal Error'
        html_part do
          body File.read('/home/hudson/logs/sinatra_server_log.txt')
        end
      end
      return false
    else
      return true
    end
  end

  def validate_patchset(input)
    if /^\d+\/\d+\/\d+$/.match(input) == nil
      Writer.write_file(Files::ERROR_FILE, 'patchset validation failed')
      exit! 1
    end
  end

  def validate_gerrit_url(input)
    if /^git fetch ssh:\/\/[a-z0-9]+@[a-z0-9]+.[a-z0-9]+.com:29418\/[a-z0-9]*.*refs\/changes\/\d+\/\d+\/\d+ && git (checkout|cherry-pick) FETCH_HEAD$/.match(input) == nil
      Writer.write_file(Files::ERROR_FILE, 'url validation failed')
      exit! 1
    end
  end
  module_function :check_error_file
  module_function :validate_patchset
  module_function :validate_gerrit_url
end
