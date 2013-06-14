require 'fileutils'
require 'active_record'
require File.expand_path(File.dirname(__FILE__) + '/../../app/models/portal_data')
require File.expand_path(File.dirname(__FILE__) + '/dirs')
require File.expand_path(File.dirname(__FILE__) + '/files')
require File.expand_path(File.dirname(__FILE__) + '/tools')
require File.expand_path(File.dirname(__FILE__) + '/writer')
require File.expand_path(File.dirname(__FILE__) + '/git')
require File.expand_path(File.dirname(__FILE__) + '/connection')

module BTools
  def BTools.basic_update
    system("git fetch")
    system("git rebase origin/master")
  end

  def BTools.reset_update_plugins
    reset_branch
    basic_update
    checkout_all_plugins
  end
  
  def BTools.kill_all_jobs
    delayed_jobs('stop')
    sleep 3 #give delayed jobs some time to shutdown
    system("kill -9 $(ps aux|grep delayed | awk '{print $2}')")
  end
  
  def BTools.clear_log_files
    FileUtils.rm_rf('log/*.log')
  end
  
  def BTools.recreate_cassandra_keyspace
    sleep 5 #just incase cassandra isn't ready
    system("cassandra-cli -f #{Dirs::FILES}/cassandra.txt")
  end
  
  def BTools.create_pg_extension
    `sudo -su postgres psql -d canvas_production -c "CREATE EXTENSION pg_trgm"`
  end
  
  def BTools.enable_features
    system('export RAILS_ENV=production;')
    system('RAILS_ENV=production bundle exec script/runner ~/files/features.rb')
  end
  
  def BTools.replace_files(options = {})
    system("echo 'package_assets: always' > config/assets.yml.tmp")
    system("cat config/assets.yml >> config/assets.yml.tmp")
    system("mv config/assets.yml.tmp config/assets.yml")
    system("cp #{options[:file]} config/environments/") unless options.empty?
    File.delete(Files::ERROR_FILE) if File.exists? Files::ERROR_FILE
  end
  
  def BTools.delayed_jobs(action = 'start')
    system("#{Dirs::CANVAS}/script/delayed_job #{action}")
  end
  
  def BTools.bundle
    FileUtils.rm_rf("#{Dirs::CANVAS}/Gemfile.lock")
    system('bundle install')
  end

  def BTools.create_migrate_assets(drop = false)
    if drop
      drop_create_output = `export RAILS_ENV=production; bundle exec rake db:drop db:create`
      check_for_error($?, "use advanced option 'View Server Log' for more info -- problem with db:drop or db:create: #{drop_create_output}")
      create_pg_extension
      migrate_output = `export RAILS_ENV=production; bundle exec rake db:migrate`
      check_for_error($?, "use advanced option 'View Server Log' for more info -- problem with db:migrate #{migrate_output}")
      lid_output = `export RAILS_ENV=production; bundle exec rake db:load_initial_data`
      check_for_error($?, "use advanced option 'View Server Log' for more info -- problem with db:load_initial_data #{lid_output}") 
      assets_output = `export RAILS_ENV=production; bundle exec rake canvas:compile_assets[false]`
      check_for_error($?, "use advanced option 'View Server Log' for more info -- problem with canvas:compile_assets: #{assets_output}")
    else
      c_m_assets_output = `export RAILS_ENV=production; bundle exec rake db:create db:migrate canvas:compile_assets[false]`
      check_for_error($?, "use advanced option 'View Server Log' for more info -- problem with db:migrate or canvas:compile_assets: #{c_m_assets_output}")
    end
  end

  def BTools.full_update(recreate_database = false, setup = true)
    bundle
    system("cp #{Dirs::FILES}/portal.rake #{Dirs::CANVAS}/lib/tasks/")
    if recreate_database
      kill_all_jobs
      kill_database_connections
      create_migrate_assets(true)
      enable_features
    else
      create_migrate_assets
    end
    post_setup if setup
  end
  
  def BTools.check_for_error(exit_status, error_content = "error: use advanced option 'View Server Log' for more info")
    if exit_status.to_i != 0
      Writer.write_file(Files::ERROR_FILE, error_content)
      reset_branch
      raise error_content
    end
  end
  
  def BTools.load_initial_data
    require "#{Dirs::CANVAS}/config/environment" unless defined?(RAILS_ROOT)
    system('export RAILS_ENV=production; bundle exec rake db:load_initial_data')
  end

  def BTools.remove_rebase_file
    FileUtils.rm_rf("#{Dirs::CANVAS}/.git/rebase-apply")
  end

  def BTools.documentation
    system('export RAILS_ENV=production; bundle exec rake doc:api')
    Tools.apache_server('start') 
  end
  
  def BTools.generate_documentation
    system('export RAILS_ENV=production; bundle exec rake doc:api')
  end
  
  def BTools.reset_branch
    remove_rebase_file
    system("git reset --hard origin/master")
    system('git checkout master')
    system('git branch -D portalPatchset')
  end
  
  def BTools.reset_branch_options(branch)
    remove_rebase_file
    branch == 'master' ? system("git reset --hard origin/master") : system("git reset --hard")
  end
  
  def BTools.generate_origin_url(origin)
    clone_statement = ''
    if origin == nil
     clone_statement = 'git clone'
    else
     origin_parts = origin.split('/')
     formatted_origin = "#{origin_parts[1]}/#{origin_parts[2]}"
     clone_statement = "git clone -b #{formatted_origin}"
    end
    clone_statement
  end
  
  def BTools.checkout_plugin(plugin, origin = nil)
    clone_statement = generate_origin_url(origin)
    if plugin == 'Analytics'
      plugin = 'canvalytics'
      system("#{clone_statement} #{Tools::GERRIT_URL}/#{plugin}.git vendor/plugins/analytics")
    elsif plugin == 'QTI Migration Tool'
      plugin = 'QTIMigrationTool'
      system("#{clone_statement} #{Tools::GERRIT_URL}/#{plugin}.git vendor/#{plugin}")
    else
      plugin.downcase!
      plugin.gsub!(' ', '_')
      system("#{clone_statement} #{Tools::GERRIT_URL}/#{plugin}.git vendor/plugins/#{plugin}")
    end
  end
  
  def BTools.remove_plugin(plugin)
    FileUtils.rm_rf("vendor/plugins/#{plugin}")
    remove_demo_site_symlinks if plugin == 'demo_site'
  end

  def BTools.update_plugin(plugin)
    if plugin == 'QTIMigrationTool'
      exists = system("cd /vendor/#{plugin}")
    else
      exists = system("cd /vendor/plugins/#{plugin}")
    end
    if exists
      reset_branch
      basic_update
    else
      puts "#{plugin} is not checked out"
    end
  end
  
  def BTools.remove_all_plugins
    FileUtils.rm_rf("vendor/plugins/analytics")
    FileUtils.rm_rf("vendor/QTIMigrationTool")
    Tools::PLUGINS.each { |plugin| FileUtils.rm_rf("vendor/plugins/#{plugin}") }
    remove_analytics_symlinks
    remove_demo_site_symlinks
    puts "all plugins removed"
  end
  
  def BTools.checkout_or_remove(do_remove, plugin)
    do_remove ? remove_plugin(plugin) : checkout_plugin(plugin)
  end
  
  def BTools.remove_analytics_symlinks
    FileUtils.rm_rf("app/views/jst/plugins/analytics")
    FileUtils.rm_rf("public/plugins/analytics")
    FileUtils.rm_rf("public/javascripts/plugins/analytics")
    FileUtils.rm_rf("public/optimized/plugins/analytics")
  end
  
  def BTools.remove_demo_site_symlinks
    FileUtils.rm_rf("public/plugins/demo_site")
    FileUtils.rm_rf("public/javascripts/plugins/demo_site")
    FileUtils.rm_rf("public/optimized/plugins/demo_site")
  end
  
  def BTools.kill_database_connections
    drop_command = "select pg_terminate_backend(procpid) from pg_stat_activity where datname='canvas_production';"
    drop_command_queue = "select pg_terminate_backend(procpid) from pg_stat_activity where datname='canvas_queue_production';"
    system("sudo -u postgres psql -c \"#{drop_command}\"")
    system("sudo -u postgres psql -c \"#{drop_command_queue}\"")
    system("psql -U canvas -c 'drop database canvas_production;'")
    system("psql -U canvas -c 'create database canvas_production;'")
    create_pg_extension
    system("psql -U canvas -c 'drop database canvas_queue_production;'")
    system("psql -U canvas -c 'create database canvas_queue_production;'")
  end
  
  def BTools.checkout_all_plugins(do_remove = true, origin = nil)
    remove_all_plugins if do_remove
    clone_statement = generate_origin_url(origin)
    system("#{clone_statement} #{Tools::GERRIT_URL}/canvalytics.git vendor/plugins/analytics")
    system("#{clone_statement} #{Tools::GERRIT_URL}/qti_migration_tool.git vendor/QTIMigrationTool")
    Tools::PLUGINS.each { |plugin| checkout_plugin(plugin, origin) }
  end
  
  def BTools.database_dcm_initial_data(load_initial_data = true)
    kill_database_connections
    migrate_output = `export RAILS_ENV=production; bundle exec rake db:migrate`
    if migrate_output.include?("rake aborted")
      Writer.write_file(Files::ERROR_FILE, "use advanced option 'View Server Log' for more info -- migration error: #{migrate_output}")
      exit! 1
    end
    if load_initial_data
      system('export RAILS_ENV=production; bundle exec rake db:load_initial_data')
    end
  end

  def BTools.pre_setup
    system('sudo service cassandra restart')
    kill_all_jobs
    Tools.apache_server('stop')
    clear_log_files
    recreate_cassandra_keyspace
  end

  def BTools.swap_env_file(localize = false)
    localize ? replace_files(:file => "#{Dirs::FILES}/localization/production.rb") : replace_files
  end

  def BTools.check_action_flags
    Connection.manage_connection do
      pd = PortalData.first
      generate_documentation if pd.documentation 
      pd.localization ? swap_env_file(true) : swap_env_file
    end
  end

  def BTools.post_setup(lid = false)
    check_action_flags
    version = `rbenv global`.strip!
    system("sudo su - root -c 'cat #{Dirs::FILES}/passenger_one_eight.txt > /etc/apache2/httpd.conf'") if version == 'ree-1.8.7-2011.03'
    system("sudo su - root -c 'cat #{Dirs::FILES}/passenger_one_nine.txt > /etc/apache2/httpd.conf'") if version == '1.9.3-p286'
    delayed_jobs
    system('redis-cli flushall')
    load_initial_data if lid
    Tools.apache_server('start')
  end
  
  def BTools.checkout(url, update = true)
    reset_update_plugins
    system("git checkout -b portalPatchset origin/master")
    `#{url}`
    if $?.exitstatus == 128
      Writer.write_file(Files::ERROR_FILE, 'fatal error checking out patchset, are you sure that is the right patchset?')
      reset_branch
      exit! 1
    end
    checkout_status = `git status 2>&1`
    if checkout_status.include?('error:')
      Writer.write_file(Files::ERROR_FILE, checkout_status)
      reset_branch
      exit! 1
    end
    full_update if update
  end
  
  def BTools.checkout_patchset_and_plugin(patchsets)
    values = patchsets.split('*')
    patchset = values.first
    plugin = values.last
    url = Tools.checkout_command(patchset)
    checkout(url, false)
    plugin_patchset(plugin, false)
  end

  def BTools.checkout_multiple_plugins(plugins)
    reset_update_plugins
    plugins.each do |plugin|
      plugin_project = plugin.split(":29418/").last.split(" ").first
      plugin_patchset = plugin.split("changes/").last.split(" ").first
      target = ''
      if plugin_project == 'qti_migration_tool'
        target = 'vendor/'
        plugin_project = 'QTIMigrationTool'	
      else
        target = 'vendor/plugins/'
      end	
      Dir.chdir "#{Dirs::CANVAS}/#{target}#{plugin_project}" do 
      system("git fetch #{Tools::GERRIT_URL}/#{plugin_project} refs/changes/#{plugin_patchset} && git checkout FETCH_HEAD")
      end     
    end
    full_update
  end

  def BTools.checkout_multiple(patchsets)
    reset_update_plugins
    patchsets.each do |patchset|
      `git fetch #{Tools::GERRIT_URL}/canvas-lms.git refs/changes/#{patchset} && git cherry-pick FETCH_HEAD`
      if $?.exitstatus != 0
        Writer.write_file(Files::ERROR_FILE, 'there were conflicts checking out one or more of the patchsets, please make sure all patchsets are in the correct order and have all been rebased recently')
        reset_branch
        exit! 1
      end
    end
    full_update
  end
 
  def BTools.reset_database
    bundle
    database_dcm_initial_data
    enable_features
    post_setup(false)
  end

  def BTools.canvas_master
    Connection.manage_connection do
      pd = PortalData.first
      reset_database = pd.old_branch
      reset_update_plugins
      output = `git checkout master`
      if(output.include?('error:'))
        Writer.write_file(Files::ERROR_FILE, output)
        reset_branch
        exit! 1
      end
      if reset_database
        full_update(true)
        pd.update_attributes({old_branch: nil})
      else
        full_update
      end
    end  
  end

  def BTools.branch(branch_name)
    reset_branch
    basic_update
    Connection.manage_connection do
      PortalData.first.update_attributes({old_branch: true})
    end
    checkout_all_plugins(true, branch_name)
    branch_command = "git checkout #{branch_name}"
    output = `#{branch_command}`
    if(output.include?('error:'))
      Writer.write_file(Files::ERROR_FILE, output)
      reset_branch
      exit! 1
    end
    full_update(true)
  end

  def BTools.change_version(branch)
    reset_branch_options(branch)
    checkout_all_plugins
    basic_update
    full_update
  end

  def BTools.plugin_patchset(value, reset = true)
    reset_update_plugins if reset
    values = value.split(' ')
    plugin = values[2].split('/').last
    checkout_command = "git fetch #{Tools::GERRIT_URL}/#{plugin} #{values[3]} && git checkout FETCH_HEAD"
    dir_name = 'analytics' if plugin == 'canvalytics'
    Dir.chdir("#{Dirs::CANVAS}/vendor/plugins/#{dir_name || plugin}") do
      reset_branch
      basic_update
      `#{checkout_command}`
      if $?.exitstatus == 128
        Writer.write_file(Files::ERROR_FILE, "fatal error checking out patchset, are you sure that is the right patchset for #{plugin}?")
        reset_branch
        exit! 1
      end
      checkout_status = `git status 2>&1`
      if checkout_status.include?('Unmerged')
        Writer.write_file(Files::ERROR_FILE, checkout_status)
        reset_branch
        exit! 1
      end
    end
    full_update
  end
end
