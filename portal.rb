require 'rubygems'
require 'sinatra'
require 'sinatra/minify'
require 'active_record'
require 'sinatra/activerecord'
require 'benchmark'
require 'sqlite3'
require 'active_support'
require 'active_support/core_ext/time/zones'
require 'active_support/time_with_zone'
require 'mail'
require 'yaml'
require 'haml'
require File.expand_path(File.dirname(__FILE__) + '/lib/helpers/html')
require File.expand_path(File.dirname(__FILE__) + '/lib/helpers/db')
require File.expand_path(File.dirname(__FILE__) + '/lib/helpers/action_time')
require File.expand_path(File.dirname(__FILE__) + '/app/models/portal_data')
require File.expand_path(File.dirname(__FILE__) + '/app/models/action_times')

ROUTES = %w[branch master_canvas_net canvasnet_patchset checkout checkout_multiple checkout_multiple_plugins plugin_patchset patchset_and_plugin dcm_initial_data change_version]
PORTAL_CONFIG = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/config/portal.yml'))
Mail.defaults do
  delivery_method :smtp, { :address   => PORTAL_CONFIG['sendgrid']['address'],
                           :port      => PORTAL_CONFIG['sendgrid']['port'],
                           :domain    => PORTAL_CONFIG['sendgrid']['domain'],
                           :user_name => PORTAL_CONFIG['sendgrid']['username'],
                           :password  => PORTAL_CONFIG['sendgrid']['password'],
                           :authentication => PORTAL_CONFIG['sendgrid']['authentication'],
                           :enable_starttls_auto => PORTAL_CONFIG['sendgrid']['starttls_auto'] }
end

class Portal < Sinatra::Application
  register Sinatra::Minify
  register Sinatra::ActiveRecordExtension
  helpers Sinatra::HtmlHelpers
  helpers Sinatra::DB
  helpers Sinatra::ActionTime
 
  set :database, 'sqlite:///portal.db'
  set :public_folder, 'public', File.dirname(__FILE__)
  set :root, 'app', File.dirname(__FILE__) 
  set :js_path, 'public/javascripts'
  set :js_url, '/javascripts'

  require_relative 'lib/init'
  require_relative 'app/routes/init'
  
  def route
    request.path_info.split('/')[1]
  end
  
  def correct_route?
    ROUTES.include? route
  end
 
  def clear_flags
    update_fields({branch: nil, patchset: nil, plugin: nil, multiple: nil, localization: nil, documentation: nil})
  end

  before do
    @start_time = Time.now.to_f
    if correct_route?
      Files.remove_error_file
      clear_flags
      update_fields({generating: true})
    end
  end

  after do
    PortalData.create! if PortalData.first == nil
    update_fields({generating: false}) if PortalData.first.generating != false
    store_action_time(route, (Time.now.to_f - @start_time)) if correct_route? && Validation.check_error_file
    if correct_route? && Validation.check_error_file == false 
      status 400
      response.write(File.open(Files::ERROR_FILE).gets)
    end
  end
end
