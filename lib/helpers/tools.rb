module Tools
  SUPPORTED_PLUGINS = "Analytics,QTI Migration Tool,Banner Grade Export Plugin,Canvas Zendesk Plugin,Custom Reports,Demo Site,IMS ES Importer Plugin,Instructure Misc Plugin,Migration Tool,Multiple Root Accounts,Phone Home Plugin, Canvasnet Registration"

  GERRIT_FORMATTED_PLUGINS = ['canvalytics', 'QTIMigrationTool', 'banner_grade_export_plugin', 'canvas_zendesk_plugin', 'custom_reports', 'demo_site', 'ims_es_importer_plugin', 'instructure_misc_plugin', 'canvasnet_registration', 'migration_tool', 'multiple_root_accounts', 'phone_home_plugin']

  GERRIT_URL = "ssh://hudson@10.86.151.193/home/gerrit"

  def one_eight_command(command)
    system("bash -lc 'rbenv shell ree-1.8.7-2011.03 && rbenv rehash && #{command}'")
  end

  def one_nine_command(command)
    system("bash -lc 'rbenv shell 1.9.3-p286 && rbenv rehash && #{command}")
  end

  def apache_server(action)
    system("sudo service apache2 #{action}")
  end

  def shut_down_portal
    system("sudo shutdown -h now")
  end

  def restart_jobs(dir, one_eight = false)
    Dir.chdir(dir) { one_eight ? one_eight_command('bundle update && bundle exec script/delayed_job restart') : system('bundle update && bundle exec script/delayed_jobs restart') }
  end
  module_function :one_eight_command
  module_function :one_nine_command
  module_function :apache_server
  module_function :shut_down_portal
  module_function :restart_jobs
end