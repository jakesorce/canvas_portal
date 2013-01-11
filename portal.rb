require 'rubygems'
require 'sinatra'
require 'sinatra/minify'
require 'active_record'
require 'benchmark'
require 'active_support'
require 'active_support/core_ext/time/zones'
require 'active_support/time_with_zone'
require 'mail'
require 'yaml'

BRANCH_FILE = "/home/hudson/files/branch.txt"
PATCHSET_FILE = "/home/hudson/files/patchset.txt"
ERROR_FILE = "/home/hudson/files/error.txt"
PLUGIN_FILE = "/home/hudson/files/plugin.txt"
INFO_FILE = "/home/hudson/files/portal_info.txt"
MULTIPLE_FILE = "/home/hudson/files/multiple.txt"
SUPPORTED_PLUGINS = "Analytics,QTI Migration Tool,Banner Grade Export Plugin,Canvas Zendesk Plugin,Custom Reports,Demo Site,IMS ES Importer Plugin,Instructure Misc Plugin,Migration Tool,Multiple Root Accounts,Phone Home Plugin, Canvasnet Registration"
GERRIT_FORMATTED_PLUGINS = ['canvalytics', 'QTIMigrationTool', 'banner_grade_export_plugin', 'canvas_zendesk_plugin', 'custom_reports', 'demo_site', 'ims_es_importer_plugin', 'instructure_misc_plugin', 'canvasnet_registration', 'migration_tool', 'multiple_root_accounts', 'phone_home_plugin']
EMAIL = YAML.load_file('config/email.yml')
Mail.defaults do
  delivery_method :smtp, { :address   => "smtp.sendgrid.net",
                           :port      => 587,
                           :domain    => "instructure.com",
                           :user_name => EMAIL['username'],
                           :password  => EMAIL['password'],
                           :authentication => 'plain',
                           :enable_starttls_auto => true }
end

class Portal < Sinatra::Base
  register Sinatra::Minify
  
  set :js_path, 'public/javascripts'
  set :js_url,  '/javascripts'

  def write_response(file)
     file_to_write = File.open(file)
     response.write(file_to_write.gets)
  end
  
  def store_action_time(action, execution_time)
    require File.expand_path(File.dirname(__FILE__) + '/config/action_time_schema')
    action = ActionTimes.find_or_create_by_action(action)
    action.update_attributes({:time => (execution_time.round * 1000)})
  end
  
  def write_file(file_path, contents)
    File.open(file_path, "w") { |file| file.write(contents) }
  end
  
  def write_info(portal_action)
    utc_offset = -7
    zone = ActiveSupport::TimeZone[utc_offset].name
    Time.zone = zone
    current_time = Time.zone.now
    formatted_time = current_time.strftime("%m/%d/%Y at %I:%M%p")
    write_file(INFO_FILE, "#{formatted_time}\n#{portal_action}")
  end
  
  def remove_files
    system("rm #{BRANCH_FILE}") if File.exists? BRANCH_FILE
    system("rm #{PATCHSET_FILE}") if File.exists? PATCHSET_FILE
    system("rm #{PLUGIN_FILE}") if File.exists? PLUGIN_FILE
    system("rm #{MULTIPLE_FILE}") if File.exists? MULTIPLE_FILE
  end
  
  def check_error_file
    if File.exists? ERROR_FILE
      status 409
      write_response(ERROR_FILE)
      system("rm #{INFO_FILE}")
      mail = Mail.deliver do
        to EMAIL['emails']
        from 'Portal V3 Adam <portalv3adam@instructure.com>'
        subject 'Portal Error Adam'
        html_part do
          body File.read('../logs/sinatra_server_log.txt')
        end
      end
      return false
    else
      return true
    end
  end

  get '/' do
    info_file = "/home/hudson/files/portal_info.txt"
    error_file = "/home/hudson/files/error.txt"
    error_text = "error occurred on last action, try again"
    no_action_text = "no portal action has taken place"
    dt_last_action = no_action_text
    last_action = no_action_text
    if File.exists? info_file
      dt_last_action = File.readlines(info_file).first
      last_action = File.readlines(info_file).last
    elsif File.exists? error_file
      dt_last_action = error_text
      last_action = error_text
    end
    apache_pid_file = "/var/run/apache2.pid"
    pid = File.open(apache_pid_file) { |file| file.gets } if File.exist?(apache_pid_file)
    if pid == nil
      erb :index
    else
      plugin_info = File.open(PLUGIN_FILE) { |file| file.gets } if File.exists? PLUGIN_FILE
      patchset = File.open(PATCHSET_FILE) { |file| file.gets } if File.exists? PATCHSET_FILE
      patchsets = File.open(MULTIPLE_FILE) { |file| file.gets }.split(',') if File.exists? MULTIPLE_FILE
      branch = File.readlines(BRANCH_FILE).first rescue Dir.chdir('/home/hudson/canvas-lms') { `git rev-parse --abbrev-ref HEAD` }
      erb :server_status, :locals => {:branch => branch, :plugin_info => plugin_info, :patchset => patchset, :patchsets => patchsets}
    end
  end
  
  get "/branch_list" do
    Dir.chdir('/home/hudson/canvas-lms') do
      available_branches = `git branch -r`
      response.write(available_branches)
    end
  end
  
  get "/plugins_list" do
    response.write(SUPPORTED_PLUGINS)
  end
  
  get "/ruby_version" do
    response.write(`rbenv global`)
  end
  
  get "/action_time" do
    require File.expand_path(File.dirname(__FILE__) + '/config/action_time_schema')
    user_action = params.keys[0]
    action = ActionTimes.find_by_action(user_action)
    time = 0
    time = action.time if action != nil
    response.write(time)
    status 200
  end
  
  post "/localization" do
    execution_time = Benchmark.realtime do
      write_info('localization validation')
      system("ruby /home/hudson/canvas-lms/branch_tools.rb -l 'localize'")
    end
    store_action_time('localization', execution_time) if check_error_file
  end
  
  post "/change_version" do
    execution_time = Benchmark.realtime do
      write_info('change ruby version')
      version = params.keys[0]
      system("rbenv global #{version}")
      system("rbenv rehash")
      system("bash -lc 'rbenv shell #{version} && rbenv rehash && ruby /home/hudson/canvas-lms/branch_tools.rb -v #{version}'")
    end
    store_action_time('change_version', execution_time) if check_error_file
  end
  
  post "/checkout" do
    remove_files
    execution_time = Benchmark.realtime do
      write_info('patchset checkout')
      patchset = params.keys[0]
      write_file(PATCHSET_FILE, patchset)
      checkout_command = "git fetch ssh://hudson@10.86.151.193/home/gerrit/canvas-lms.git refs/changes/#{patchset} && git checkout FETCH_HEAD"
      branch_tools_command = "ruby /home/hudson/canvas-lms/branch_tools.rb -c '#{checkout_command}'"
      system(branch_tools_command)
    end
    store_action_time('checkout', execution_time) if check_error_file
  end

  post "/checkout_multiple" do
    remove_files
    execution_time = Benchmark.realtime do
      patchsets = params.keys[0]
      write_info('multiple patchset checkout')
      write_file(MULTIPLE_FILE, patchsets)
      system("ruby /home/hudson/canvas-lms/branch_tools.rb -m '#{patchsets}'")
    end
    store_action_time('checkout_multiple', execution_time) if check_error_file
  end
  
  post "/plugin_patchset" do
    remove_files
    execution_time = Benchmark.realtime do
      write_info('plugin patchset checkout')
      plugin_checkout_values = []
      url = params.values[0]
      url_parts = url.split(' ')
      plugin = url_parts[2].split('/')[3]
      if !GERRIT_FORMATTED_PLUGINS.include?(plugin)
        status 400
        response.write("plugin is not in the list of supported plugins, click the '?' button to see what plugins are supported and try again")
      else
        plugin_patchset = url_parts[3].split('changes')[1]
        write_file(PATCHSET_FILE, plugin_patchset)
        write_file(PLUGIN_FILE, " - this is a plugin patchset for #{plugin}")
        checkout_command = "git fetch ssh://hudson@10.86.151.193/home/gerrit/#{plugin}.git refs/changes#{plugin_patchset} && git checkout FETCH_HEAD"
        plugin_checkout_values << plugin_patchset + "*"
        plugin_checkout_values << plugin + "*"
        plugin_checkout_values << checkout_command
        branch_tools_command = "ruby /home/hudson/canvas-lms/branch_tools.rb -p '#{plugin_checkout_values}'"
        system(branch_tools_command)
      end
    end
    store_action_time('plugin_patchset', execution_time) if check_error_file
  end
  
  post "/branch" do
    remove_files
    execution_time = Benchmark.realtime do
      write_info('branch checkout')
      branch = params.keys[0]
      write_file(BRANCH_FILE, branch)
      system("ruby /home/hudson/canvas-lms/branch_tools.rb -b '#{branch}'")
    end
    store_action_time('branch', execution_time) if check_error_file
  end
  
  post "/master_canvas_net" do
    remove_files
    branch = 'canvas network master'
    write_info(branch)
    write_file(BRANCH_FILE, branch)
    net_pids = '/home/hudson/udemodo/tmp/pids/delayed_job.pid'
    File.open(net_pids).each { |line| system("kill -9 #{line}") } if File.exists? net_pids
    system('rbenv global ree-1.8.7-2011.03')
    system('rbenv rehash')
    execution_time = Benchmark.realtime do
      Dir.chdir('/home/hudson/udemodo') do
        system('echo "development: 
          adapter: mysql2 
          encoding: utf8 
          database: udemodo 
          host: localhost 
          port: 3306 
          username: root 
          password: swordfish 
          timeout: 5000" > config/database.yml')
        system('bundle update')
        system("RAILS_ENV='development' bundle exec rake db:drop db:create db:migrate")
        system('bundle exec rake import:courses')
        system("sudo su - root -c 'cat /home/hudson/files/passenger_udemodo.txt > /etc/apache2/httpd.conf'")
        system('bundle exec script/delayed_job start')
        system('sudo apachectl start')
      end
    end
    store_action_time('master_canvas_net', execution_time) if check_error_file
  end
  
  post "/dcm_initial_data/:environment" do |environment|
    execution_time = Benchmark.realtime do
      write_info('reset database')
      system("ruby /home/hudson/canvas-lms/branch_tools.rb -d '#{environment}'")
    end
    store_action_time('dcm_initial_data', execution_time) if check_error_file
  end
  
  post "/apache_server/:action" do |action|
    system("sudo service apache2 #{action}")
  end
  
  post "/documentation" do
    execution_time = Benchmark.realtime do
      write_info('generate documentation')
      system("ruby /home/hudson/canvas-lms/branch_tools.rb -g 'true'")
    end
    store_action_time('documentation', execution_time) if check_error_file
  end

  post '/shutdown' do
    execution_time = Benchmark.realtime do
      write_info('shut down portal')
      system("sudo shutdown -h now")
    end
    store_action_time('shutdown', execution_time)
  end
end
