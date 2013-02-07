ENV["HOME"] ||= "/home/hudson/canvas-lms/public" 
ENV["RAILS_ENV"] = 'development'
ENV['CANVAS_LMS_ADMIN_EMAIL']='test'
ENV['CANVAS_LMS_ADMIN_PASSWORD']='password'
ENV['CANVAS_LMS_ACCOUNT_NAME']='QA Testing'
ENV["CANVAS_LMS_STATS_COLLECTION"]='opt_out'

Dir.chdir('/home/hudson/canvas-lms') do
  BTools.pre_setup
  case action
    when 'checkout'
      BTools.checkout(options[:checkout_url])
    when 'checkout multiple'
      BTools.checkout_multiple(options[:patchsets].split(','))
    when 'dump database'
      BTools.reset_database
    when 'use master'
      BTools.canvas_master
    when 'use branch'
      BTools.branch(options[:branch_name])
    when 'generate documentation'
      BTools.documentation
    when 'localize'
      BTools.localize
    when 'ruby version change'
      BTools.change_version(options)
    when 'plugin patchset'
      BTools.plugin_patchset(options[:plugin_for_patchset], options[:plugin_checkout_command])
  end
end
