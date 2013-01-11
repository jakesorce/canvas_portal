#!/usr/bin/env ruby
require 'optparse'
ERROR_FILE = "/home/hudson/files/error.txt"
OLD_BRANCH_FILE = '/home/hudson/files/old_branch.txt'
# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {}
action = ''

optparse = OptionParser.new do |opts|
  # Define the options, and what they do
  opts.on('-c', '--checkout URL', 'updates, does a git checkout, server') do |checkout_url|
    options[:checkout_url] = checkout_url
    action = 'checkout'
  end

  opts.on('-d', '--dump database', 'dumps development database and runs modified load initial data rake task') do |database|
    options[:database] = database
    action = 'dump database'
  end

  opts.on('-b', '--branch name', 'switches to the branch, resets it, runs migrations and assets, and server') do |branch_name|
    options[:branch_name] = branch_name
    options[:branch_name] == 'master' ? action = 'use master' : action = 'use branch'
  end
  
  opts.on('-r', '--remove plugins', '[all] will remove all plugins') do |plugins_option|
    options[:plugins_option] = plugins_option
    action = 'remove plugins'
  end

  opts.on('-e', '--enable features', 'enables features') do |feature_option|
    options[:feature_option] = feature_option
    action = 'enable features'  
  end

  opts.on('-g', '--generate documentation', 'generates documentation') do |generate|
    options[:generate_documentation] = generate
    action = 'generate documentation'
  end

  opts.on('-p', '--plugin patchset', 'checks out a patchset of a given plugin') do |plugin_checkout_values|
    value_parts = plugin_checkout_values.split('*')
    options[:plugin_patchset] = value_parts[0]
    options[:plugin_for_patchset] = value_parts[1]
    options[:plugin_checkout_command] = value_parts[2]
    action = 'plugin patchset'
  end
  
  opts.on('-l', '--validate localization', 'adds code to development.rb to help check localization') do |localize|
     action = 'localize'
   end
  
  opts.on('-v', '--ruby version change', 'executes code needed to do necessary canvas restart after a version change') do |version|
    options[:ruby_version] = version
    action = 'ruby version change'
  end
  
  opts.on('-m', '--multiple patchset checkout', 'checkout each patchset in order from first to last on top of the master branch') do |patchsets|
    options[:patchsets] = patchsets
    action = 'checkout multiple'
  end

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end

# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!

ENV["HOME"] ||= "/home/hudson/canvas-lms/public" 
ENV["RAILS_ENV"] = 'development'
ENV['CANVAS_LMS_ADMIN_EMAIL']='test'
ENV['CANVAS_LMS_ADMIN_PASSWORD']='password'
ENV['CANVAS_LMS_ACCOUNT_NAME']='QA Testing'
ENV["CANVAS_LMS_STATS_COLLECTION"]='opt_out'
VENDOR_PLUGINS = %w(canvasnet_registration banner_grade_export_plugin canvas_zendesk_plugin custom_reports demo_site ims_es_importer_plugin instructure_misc_plugin migration_tool multiple_root_accounts phone_home_plugin)

def basic_update
  system("git fetch")
  system("git rebase origin/master")
end

def kill_all_jobs
  File.open('/home/hudson/canvas-lms/tmp/pids/delayed_jobs_pool.pid').each { |line| system("kill -9 #{line}") }
end

def clear_log_files
  system('rm -rf log/*.log')
end

def recreate_cassandra_keyspace
  sleep 5
  system('cassandra-cli -f /home/hudson/files/cassandra.txt')
end

def enable_features
  require File.dirname(__FILE__) + "/config/environment" unless defined?(RAILS_ROOT)
  Setting.set('enable_page_views', 'db')
  Account.default.enable_service(:analytics)
  Setting.set('show_feedback_link', 'true')
  Setting.set('enable_page_views', 'cassandra')
  Account.default.tap { |a| a.settings[:enable_scheduler] = true; a.save }
  PluginSetting.new(:name => "kaltura", :settings => {"rtmp_domain"=>"rtmp.instructuremedia.com", "kcw_ui_conf"=>"1727883", "domain"=>"www.instructuremedia.com", "user_secret_key"=>"54122449a76ae10409adcefa3148f4b7", "secret_key"=>"ed7eae22d60b82e0b44fb95089ddb228", "player_ui_conf"=>"1727899", "upload_ui_conf"=>"1103", "partner_id"=>"100", "subpartner_id"=>"10000", "resource_domain"=>"www.instructuremedia.com"}).save
end

def replace_files(dev_file = "/home/hudson/files/development.rb")
  package_assets_command = "echo 'package_assets: always' > config/assets.yml.tmp"
  append_assets_file_command = "cat config/assets.yml >> config/assets.yml.tmp"
  move_assets_file_command = "mv config/assets.yml.tmp config/assets.yml"
  system("cp #{dev_file}  config/environments/")
  system("rm #{ERROR_FILE}") if File.exists? ERROR_FILE
  system(package_assets_command)
  system(append_assets_file_command)
  system(move_assets_file_command)
end

def delayed_jobs(action = 'start')
  system("/home/hudson/canvas-lms/script/delayed_job #{action}")
end

def bundle
  system('bundle update')
end

def full_update(recreate_database = false)
  bundle
  delete_command_1 = "delete from schema_migrations where version = '20121107163612';"
  delete_command_2 = "delete from schema_migrations where version = '20121016150454';"
  system("sudo -u postgres psql -c \"#{delete_command_1}\"")
  system("sudo -u postgres psql -c \"#{delete_command_2}\"")
  system("cp /home/hudson/files/portal.rake /home/hudson/canvas-lms/lib/tasks/")
  if recreate_database
    delayed_jobs('stop')
    kill_database_connections
    `bundle exec rake db:drop db:create db:migrate portal:compile_assets[false]`
  else
    `bundle exec rake db:create db:migrate portal:compile_assets[false]`
  end
  check_for_error($?.exitstatus)
end

def write_to_file(file, content)
  File.open(file, "w") { |file| file.write(content) }
end

def check_for_error(exit_status, error_content = "error")
  if exit_status == 1
    write_to_file(ERROR_FILE, error_content)
    reset_branch
    exit! 1
  end
end

def apache_action(action)
  system("sudo /etc/init.d/apache2 #{action}")
end

def load_initial_data
  require File.dirname(__FILE__) + "/config/environment" unless defined?(RAILS_ROOT)
  system('bundle exec rake db:load_initial_data')
end

def generate_documentation
  system('bundle exec rake doc:api')
end

def reset_branch
  system('rm /home/hudson/canvas-lms/.git/rebase-apply')
  system("git reset --hard origin/master")
  system('git checkout master')
end

def reset_branch_options(options)
  system('rm /home/hudson/canvas-lms/.git/rebase-apply')
  options[:branch_name] == 'master' ? system("git reset --hard origin/master") : system("git reset --hard")
end

def generate_origin_url(origin)
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

def checkout_plugin(plugin, origin = nil)
  clone_statement = generate_origin_url(origin)
  if plugin == 'Analytics'
    plugin = 'canvalytics'
    system("#{clone_statement} ssh://hudson@10.86.151.193/home/gerrit/#{plugin}.git vendor/plugins/analytics")
  elsif plugin == 'QTI Migration Tool'
    plugin = 'QTIMigrationTool'
    system("#{clone_statement} ssh://hudson@10.86.151.193/home/gerrit/#{plugin}.git vendor/#{plugin}")
  else
    plugin.downcase!
    plugin.gsub!(' ', '_')
    system("#{clone_statement} ssh://hudson@10.86.151.193/home/gerrit/#{plugin}.git vendor/plugins/#{plugin}")
  end
end

def remove_plugin(plugin)
  system("rm -rf vendor/plugins/#{plugin}")
  remove_demo_site_symlinks if plugin == 'demo_site'
end

def update_plugin(plugin)
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

def remove_all_plugins
  system("rm -rf vendor/plugins/analytics")
  system("rm -rf vendor/QTIMigrationTool")
  VENDOR_PLUGINS.each { |plugin| system("rm -rf vendor/plugins/#{plugin}") }
  remove_analytics_symlinks
  remove_demo_site_symlinks
  puts "all plugins removed"
end

def checkout_or_remove(do_remove, plugin)
  do_remove ? remove_plugin(plugin) : checkout_plugin(plugin)
end

def remove_analytics_symlinks
  system("rm -rf app/views/jst/plugins/analytics")
  system("rm -rf public/plugins/analytics")
  system("rm -rf public/javascripts/plugins/analytics")
  system("rm -rf public/optimized/plugins/analytics")
end

def remove_demo_site_symlinks
  system("rm -rf public/plugins/demo_site")
  system("rm -rf public/javascripts/plugins/demo_site")
  system("rm -rf public/optimized/plugins/demo_site")
end

def kill_database_connections
  drop_command = "select pg_terminate_backend(procpid) from pg_stat_activity where datname='canvas_development';"
  drop_command_queue = "select pg_terminate_backend(procpid) from pg_stat_activity where datname='canvas_queue_development';"
  system("sudo -u postgres psql -c \"#{drop_command}\"") 
  system("sudo -u postgres psql -c \"#{drop_command_queue}\"")
  system("psql -U canvas -c 'drop database canvas_development;'")
  system("psql -U canvas -c 'create database canvas_development;'")
  system("psql -U canvas -c 'drop database canvas_queue_development;'")
  system("psql -U canvas -c 'create database canvas_queue_development;'")
end

def checkout_all_plugins(do_remove = true, origin = nil)
  remove_all_plugins if do_remove
  clone_statement = generate_origin_url(origin)
  system("#{clone_statement} ssh://hudson@10.86.151.193/home/gerrit/canvalytics.git vendor/plugins/analytics")
  system("#{clone_statement} ssh://hudson@10.86.151.193/home/gerrit/qti_migration_tool.git vendor/QTIMigrationTool")
  VENDOR_PLUGINS.each { |plugin| checkout_plugin(plugin, origin) }
end

def database_dcm_initial_data(load_initial_data = true)
  kill_database_connections
  migrate_output = `bundle exec rake db:migrate`
  if migrate_output.include?("rake aborted")
    write_to_file(ERROR_FILE, "migration error: #{migrate_output}")
    exit! 1
  end
  if load_initial_data
    require File.dirname(__FILE__) + "/config/environment" unless defined?(RAILS_ROOT)
    system('bundle exec rake db:load_initial_data')
  end
end

def post_setup(lid = false, swap_localize_dev_file = false)
  version = `rbenv global`.strip!
  system("sudo su - root -c 'cat /home/hudson/files/passenger_one_eight.txt > /etc/apache2/httpd.conf'") if version == 'ree-1.8.7-2011.03'
  system("sudo su - root -c 'cat /home/hudson/files/passenger_one_nine.txt > /etc/apache2/httpd.conf'") if version == '1.9.3-p286'
  swap_localize_dev_file ? replace_files('/home/hudson/files/localization/development.rb') : replace_files
  delayed_jobs
  system('redis-cli flushall')
  enable_features
  load_initial_data if lid
  apache_action('start')
end

Dir.chdir('/home/hudson/canvas-lms') do
  system('sudo service cassandra restart')
  kill_all_jobs
  system('sudo killall apache2')
  clear_log_files
  recreate_cassandra_keyspace
  case action
    when 'checkout'
      checkout_url = options[:checkout_url]
      reset_branch
      basic_update
      checkout_all_plugins
      `#{checkout_url}`
      if $?.exitstatus == 128
        write_to_file(ERROR_FILE, 'fatal error checking out pathset, are you sure that is the right patchset?')
        reset_branch
        exit! 1
      end
      checkout_status = `git status 2>&1`
      if checkout_status.include?('Unmerged')
        write_to_file(ERROR_FILE, checkout_output)
        reset_branch
        exit! 1
      end
      bundle
      full_update
      post_setup(true)
    when 'checkout multiple'
      patchsets = options[:patchsets].split(',')
      reset_branch
      basic_update
      checkout_all_plugins
      patchsets.each do |patchset|
        `git fetch ssh://hudson@10.86.151.193/home/gerrit/canvas-lms.git refs/changes/#{patchset} && git cherry-pick FETCH_HEAD`
        if $?.exitstatus != 0
          write_to_file(ERROR_FILE, 'there were conflicts checking out one or more of the patchsets, please make sure all patchsets are in the correct order and have all been rebased recently')
          reset_branch
          exit! 1
        end
      end
      full_update
      post_setup(true)
    when 'dump database'
      database_dcm_initial_data
      post_setup
    when 'use master'
      reset_database = File.exists? OLD_BRANCH_FILE
      reset_branch
      basic_update
      checkout_all_plugins
      branch_command = "git checkout #{options[:branch_name]}"
      output = `#{branch_command}`
      if(output.include?('error:'))
        write_to_file(ERROR_FILE, output)
        reset_branch
        exit! 1
      end
      if reset_database
        full_update(true)
        system("rm #{OLD_BRANCH_FILE}")
      else
        full_update
      end
      post_setup
    when 'use branch'
      reset_branch
      basic_update
      write_to_file(OLD_BRANCH_FILE, 'old branch has been checked out')
      checkout_all_plugins(true, options[:branch_name])
      branch_command = "git checkout #{options[:branch_name]}"
      output = `#{branch_command}`
      if(output.include?('error:'))
        write_to_file(ERROR_FILE, output)
        reset_branch
        exit! 1 
      end
      full_update(true)
      post_setup(true)
    when 'remove plugins'
      remove_all_plugins
    when 'enable features'
      enable_features
    when 'generate documentation'
      generate_documentation
      apache_action('start')
    when 'localize'
      checkout_all_plugins
      full_update
      post_setup(true, true)
    when 'ruby version change'
      reset_branch_options(options)
      checkout_all_plugins
      basic_update
      full_update
      post_setup(true)
    when 'plugin patchset'
      plugin = options[:plugin_for_patchset]
      reset_branch
      basic_update
      checkout_all_plugins
      dir_name = 'analytics' if plugin == 'canvalytics'
      Dir.chdir("/home/hudson/canvas-lms/vendor/plugins/#{dir_name || plugin}") do
        reset_branch
        basic_update
        `#{options[:plugin_checkout_command]}`
        if $?.exitstatus == 128
          write_to_file(ERROR_FILE, "fatal error checking out pathset, are you sure that is the right patchset for #{plugin}?")
          reset_branch
          exit! 1
        end
        checkout_status = `git status 2>&1`
        if checkout_status.include?('Unmerged')
          write_to_file(ERROR_FILE, checkout_output)
          reset_branch
          exit! 1
        end
      end
      full_update
      post_setup(true)
  end
end
